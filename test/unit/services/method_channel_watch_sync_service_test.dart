import 'package:bae108_counter/models/counter_settings.dart';
import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/services/method_channel_watch_sync_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 테스트 바인딩(가짜 플랫폼 채널 사용)
  TestWidgetsFlutterBinding.ensureInitialized();
  // 테스트용 채널
  const channel = MethodChannel(WatchChannelContract.channelName);
  // 가짜 메신저
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    // 가짜 응답을 지운다.
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('sendSettings_called_sendsIntervalSeconds', () async {
    // 준비: iOS가 받은 호출을 기록한다.
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final service = MethodChannelWatchSyncService(channel: channel);

    // 실행: 15초 간격을 보낸다.
    await service.sendSettings(
      const CounterSettings(intervalSeconds: 15, alertMode: AlertMode.bell),
    );

    // 검증: 정해진 메서드와 키로 보낸다.
    expect(calls.single.method, WatchChannelContract.sendSettings);
    expect(calls.single.arguments, <String, Object>{
      WatchChannelContract.intervalSecondsKey: 15,
    });
  });

  test('sendSettings_platformError_doesNotThrow', () async {
    // 준비: iOS가 오류를 돌려준다(워치 앱 미설치 등).
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    final service = MethodChannelWatchSyncService(channel: channel);

    // 실행 및 검증: 예외 없이 끝난다.
    await expectLater(
      service.sendSettings(
        const CounterSettings(intervalSeconds: 10, alertMode: AlertMode.bell),
      ),
      completes,
    );
  });

  test('takeCompletedSessions_watchUtcRecords_convertsToLocalTime', () async {
    // 준비: iOS가 워치 기록 두 개(하나는 형식 오류)를 돌려준다.
    messenger.setMockMethodCallHandler(channel, (call) async {
      return <Object?>[
        <Object?, Object?>{
          'id': '1762300000000000',
          'startedAt': '2026-11-05T00:00:00Z',
          'endedAt': '2026-11-05T00:30:00Z',
          'activeDurationSeconds': 1800,
          'bowCount': 108,
          'memo': '',
        },
        <Object?, Object?>{'id': 'broken'},
      ];
    });
    final service = MethodChannelWatchSyncService(channel: channel);

    // 실행: 기록을 가져온다.
    final sessions = await service.takeCompletedSessions();

    // 검증: 형식이 맞는 하나만, 기기 시간대로 바뀌어 온다.
    expect(sessions, hasLength(1));
    expect(sessions.single.startedAt.isUtc, isFalse);
    expect(sessions.single.startedAt, DateTime.utc(2026, 11, 5).toLocal());
    expect(sessions.single.bowCount, 108);
  });

  test('sessionsAvailable_nativeCall_emitsEvent', () async {
    // 준비: 서비스와 알림 수신
    final service = MethodChannelWatchSyncService(channel: channel);
    final events = <void>[];
    final subscription = service.sessionsAvailable.listen(events.add);

    // 실행: iOS가 새 기록 도착을 알린다.
    await messenger.handlePlatformMessage(
      WatchChannelContract.channelName,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall(WatchChannelContract.sessionsAvailable),
      ),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    // 검증: 알림이 한 번 온다.
    expect(events, hasLength(1));
    await subscription.cancel();
  });
}
