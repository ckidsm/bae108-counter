import 'package:bae108_counter/models/bow_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// 검사할 태블릿 가로 크기
const Map<String, Size> _tabletSizes = <String, Size>{
  'iPad Pro 11': iPadLandscapeSize,
  'iPad 10.2': smallIPadLandscapeSize,
  'Android 10인치': androidTabletLandscapeSize,
  'Android 7인치': smallAndroidTabletLandscapeSize,
};

void main() {
  for (final entry in _tabletSizes.entries) {
    testWidgets('tabletLayout_${entry.key}_showsThreeColumnsWithoutOverflow', (
      tester,
    ) async {
      // 준비 및 실행: 태블릿 가로 크기로 띄운다.
      await pumpTestApp(tester, logicalSize: entry.value);

      // 검증: 넘침 없이 왼쪽·가운데·오른쪽 열 요소가 모두 보인다.
      expect(tester.takeException(), isNull);
      expect(find.text('오늘의 108배'), findsOneWidget);
      expect(find.text('연속 수행'), findsOneWidget);
      expect(find.text('이번 주'), findsOneWidget);
      expect(find.text('/ 108'), findsOneWidget);
      expect(find.text('오늘'), findsOneWidget);
      expect(find.text('남은 절'), findsOneWidget);
      expect(find.text('108배'), findsOneWidget);
      expect(find.text('처음부터'), findsOneWidget);
      expect(find.byType(Scrollable), findsNothing);
    });
  }

  testWidgets('tabletLayout_columns_areOrderedLeftCenterRight', (tester) async {
    // 준비 및 실행: iPad 가로로 띄운다.
    await pumpTestApp(tester, logicalSize: iPadLandscapeSize);

    // 검증: 연속 수행(왼쪽) < 원(가운데) < 오늘 카드(오른쪽), 버튼은 세로로 쌓인다.
    final left = tester.getCenter(find.text('연속 수행')).dx;
    final center = tester.getCenter(find.text('/ 108')).dx;
    final right = tester.getCenter(find.text('오늘')).dx;
    expect(left, lessThan(center));
    expect(center, lessThan(right));
    final start = tester.getCenter(find.text('시작'));
    final stop = tester.getCenter(find.text('정지'));
    expect(start.dy, lessThan(stop.dy));
    expect((start.dx - stop.dx).abs(), lessThan(1));
  });

  testWidgets('tabletLayout_running_updatesTodayCard', (tester) async {
    // 준비: 5초 간격이 저장된 iPad 화면
    await pumpTestApp(
      tester,
      logicalSize: iPadLandscapeSize,
      intervalSeconds: 5,
    );

    // 실행: 시작하고 준비 10초 + 5초 진행 후 정지한다(2배째).
    await tester.tap(find.text('시작'));
    await advanceSeconds(tester, 15);
    await tester.tap(find.text('정지'));
    await tester.pump();

    // 검증: 2배째, 남은 절 106배, 경과 5초가 보인다.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('106배'), findsOneWidget);
    expect(
      find.descendant(
        of: find
            .ancestor(of: find.text('경과'), matching: find.byType(Row))
            .first,
        matching: find.text('5초'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tabletLayout_savedRecords_showStreakAndWeek', (tester) async {
    // 준비: 어제와 오늘 기록이 있는 iPad 화면
    final now = DateTime.now();
    final testApp = await pumpTestApp(tester, logicalSize: iPadLandscapeSize);
    for (final day in <DateTime>[now.subtract(const Duration(days: 1)), now]) {
      await testApp.repository.addSession(
        BowSession(
          id: day.toIso8601String(),
          startedAt: day.subtract(const Duration(minutes: 30)),
          endedAt: day,
          activeDurationSeconds: 1800,
          bowCount: 108,
        ),
      );
    }

    // 실행: 다시 그린다(앱 재실행).
    await pumpTestApp(
      tester,
      logicalSize: iPadLandscapeSize,
      resetPreferences: false,
    );

    // 검증: 연속 2일이 보인다.
    expect(find.text('2일'), findsOneWidget);
  });
}
