import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/bow_session.dart';
import '../models/counter_settings.dart';
import 'watch_sync_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the method channel contract shared with the iOS AppDelegate.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// iOS 네이티브(AppDelegate.swift)와 맞춘 채널 이름과 메서드 이름.
abstract final class WatchChannelContract {
  // 채널 이름
  /// The method channel name.
  static const String channelName = 'com.ckidsm.bae108/watch';

  // Flutter → iOS: 워치로 설정 보내기
  /// Flutter → iOS: sends settings to the watch.
  static const String sendSettings = 'sendSettings';

  // Flutter → iOS: 쌓인 워치 기록 가져오기
  /// Flutter → iOS: takes the queued watch records.
  static const String takePendingSessions = 'takePendingSessions';

  // iOS → Flutter: 새 워치 기록이 도착했다는 알림
  /// iOS → Flutter: new watch records are queued.
  static const String sessionsAvailable = 'sessionsAvailable';

  // 설정 키: 절 간격(초)
  /// The settings key carrying the interval in seconds.
  static const String intervalSecondsKey = 'intervalSeconds';
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Talks to the Apple Watch through the iOS WatchConnectivity bridge.
 Remarks  : Records arrive as BowSession JSON maps with UTC ISO-8601 times.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// iOS의 WatchConnectivity 브리지를 통해 Apple Watch와 통신하는 구현.
final class MethodChannelWatchSyncService implements WatchSyncService {
  /// Creates the service on [channel] (the default channel unless a test passes one).
  MethodChannelWatchSyncService({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel(WatchChannelContract.channelName) {
    // iOS에서 오는 알림을 받는다.
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  // iOS와 통신하는 채널
  final MethodChannel _channel;
  // 새 기록 도착 알림을 화면에 전달하는 스트림
  final StreamController<void> _sessionsAvailable =
      StreamController<void>.broadcast();

  @override
  Stream<void> get sessionsAvailable => _sessionsAvailable.stream;

  @override
  Future<void> sendSettings(CounterSettings settings) async {
    // 워치는 간격만 쓴다(진동 신호는 워치에서 정해져 있다).
    try {
      // iOS로 보낸다.
      await _channel.invokeMethod<void>(
        WatchChannelContract.sendSettings,
        <String, Object>{
          WatchChannelContract.intervalSecondsKey: settings.intervalSeconds,
        },
      );
    } on PlatformException catch (error) {
      // 워치 앱이 없거나 연결 전이면 실패할 수 있다. 앱 동작은 계속한다.
      debugPrint('[WatchSync] 설정 전송 실패: $error');
    }
  }

  @override
  Future<List<BowSession>> takeCompletedSessions() async {
    // iOS에 쌓인 기록 목록
    final List<Object?>? rawSessions;
    // 채널 호출은 실패할 수 있다.
    try {
      // 쌓인 기록을 가져온다(가져가면 iOS에서는 지워진다).
      rawSessions = await _channel.invokeListMethod<Object?>(
        WatchChannelContract.takePendingSessions,
      );
    } on PlatformException catch (error) {
      // 실패하면 이번에는 빈 목록으로 처리한다(iOS 쪽 기록은 남아 있다).
      debugPrint('[WatchSync] 워치 기록 가져오기 실패: $error');
      // 빈 목록
      return <BowSession>[];
    }
    // 각 항목을 기록으로 바꾼다(형식이 틀린 항목은 건너뛴다).
    return (rawSessions ?? const <Object?>[])
        .map(parseSession)
        .whereType<BowSession>()
        .toList();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Converts one record map from the watch into a local-time BowSession.
   Remarks  : Returns null and logs when the map is malformed.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Converts [raw] into a [BowSession] in local time, or null if it is malformed.
  @visibleForTesting
  static BowSession? parseSession(Object? raw) {
    // Map이 아니면 건너뛴다.
    if (raw is! Map) {
      // 형식 오류
      debugPrint('[WatchSync] 워치 기록 형식 오류: ${raw.runtimeType}');
      // 건너뜀
      return null;
    }
    // 형식이 틀리면 예외가 난다.
    try {
      // 키를 문자열로 맞춰 기록으로 바꾼다.
      final session = BowSession.fromJson(Map<String, dynamic>.from(raw));
      // 워치는 UTC로 보내므로 화면 표시를 위해 기기 시간대로 바꾼다.
      return BowSession(
        id: session.id,
        startedAt: session.startedAt.toLocal(),
        endedAt: session.endedAt.toLocal(),
        activeDurationSeconds: session.activeDurationSeconds,
        bowCount: session.bowCount,
        memo: session.memo,
      );
    } on FormatException catch (error) {
      // 어떤 오류인지 남기고 건너뛴다.
      debugPrint('[WatchSync] 워치 기록 해석 실패: $error');
      // 건너뜀
      return null;
    }
  }

  // iOS에서 오는 호출을 처리한다.
  Future<void> _handleNativeCall(MethodCall call) async {
    // 새 기록 도착 알림이면 화면에 알린다.
    if (call.method == WatchChannelContract.sessionsAvailable) {
      // 알림 전달
      _sessionsAvailable.add(null);
    }
  }
}
