import 'package:bae108_counter/models/bow_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_services.dart';
import '../support/test_app.dart';

// 워치에서 끝낸 108배 기록을 만든다.
BowSession _watchSession(String id) {
  // 30분짜리 기록
  return BowSession(
    id: id,
    startedAt: DateTime(2026, 11, 5, 6, 0),
    endedAt: DateTime(2026, 11, 5, 6, 30),
    activeDurationSeconds: const Duration(minutes: 30).inSeconds,
    bowCount: 108,
  );
}

void main() {
  testWidgets('mainScreen_started_sendsCurrentIntervalToWatch', (tester) async {
    // 준비 및 실행: 20초 간격이 저장된 앱을 띄운다.
    final testApp = await pumpTestApp(tester, intervalSeconds: 20);

    // 검증: 워치에 20초 간격을 보낸다.
    expect(testApp.watchSyncService.sentSettings.last.intervalSeconds, 20);
  });

  testWidgets('settingsChanged_intervalChip_sendsNewIntervalToWatch', (
    tester,
  ) async {
    // 준비: 설정 화면을 연다.
    final testApp = await pumpTestApp(tester);
    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    // 실행: 5초 칩을 누른다.
    await tester.tap(find.text('5초'));
    await tester.pumpAndSettle();

    // 검증: 워치에도 5초를 보낸다.
    expect(testApp.watchSyncService.sentSettings.last.intervalSeconds, 5);
  });

  testWidgets('watchSessionsQueuedBeforeLaunch_areSavedOnStart', (
    tester,
  ) async {
    // 준비: 앱이 꺼져 있는 동안 워치 기록 하나가 쌓여 있다.
    final watchSyncService = FakeWatchSyncService()
      ..pendingSessions.add(_watchSession('watch-1'));

    // 실행: 앱을 띄운다.
    final testApp = await pumpTestApp(
      tester,
      watchSyncService: watchSyncService,
    );

    // 검증: 기록이 저장되고 안내가 뜬다.
    expect(testApp.repository.loadSessions().single.id, 'watch-1');
    expect(find.text('Apple Watch 수행 기록 1건을 저장했습니다'), findsOneWidget);
  });

  testWidgets('watchSessionsDelivered_duplicates_areSavedOnce', (tester) async {
    // 준비: 앱을 띄운다.
    final testApp = await pumpTestApp(tester);

    // 실행: 워치가 같은 기록을 두 번 보내고, 다른 기록도 하나 보낸다.
    testApp.watchSyncService.deliver(<BowSession>[
      _watchSession('watch-1'),
      _watchSession('watch-1'),
    ]);
    await tester.pumpAndSettle();
    testApp.watchSyncService.deliver(<BowSession>[
      _watchSession('watch-1'),
      _watchSession('watch-2'),
    ]);
    await tester.pumpAndSettle();

    // 검증: 서로 다른 두 건만 저장된다.
    expect(
      testApp.repository.loadSessions().map((session) => session.id).toSet(),
      <String>{'watch-1', 'watch-2'},
    );
    expect(testApp.repository.loadSessions(), hasLength(2));
  });

  testWidgets('watchSession_saved_appearsInHistory', (tester) async {
    // 준비: 워치 기록이 쌓인 상태로 앱을 띄운다.
    await pumpTestApp(
      tester,
      watchSyncService: FakeWatchSyncService()
        ..pendingSessions.add(_watchSession('watch-1')),
    );
    await tester.pump(const Duration(seconds: 5));

    // 실행: 수행 기록 화면을 연다.
    await tester.tap(find.byTooltip('수행 기록'));
    await tester.pumpAndSettle();

    // 검증: 이번 달 1회·108절로 보인다.
    expect(find.text('1회'), findsOneWidget);
    expect(find.text('108절'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
