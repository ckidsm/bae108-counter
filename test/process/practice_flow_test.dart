import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/accent_preset.dart';
import 'package:bae108_counter/models/background_preset.dart';
import 'package:bae108_counter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// 테스트에서 고르는 절 간격(초)
const int _intervalSeconds = 5;

// 5초씩 [stepCount]번 진행한다(긴 수행을 빠르게 진행하기 위함).
Future<void> advanceIntervals(WidgetTester tester, int stepCount) async {
  // 정해진 횟수만큼 간격 하나씩 진행한다.
  for (var stepIndex = 0; stepIndex < stepCount; stepIndex++) {
    // 간격 하나 진행
    await tester.pump(const Duration(seconds: _intervalSeconds));
  }
}

void main() {
  testWidgets('intervalPractice_fullFlow_savesRecordAndShowsItInHistory', (
    tester,
  ) async {
    // 준비: 5초 간격이 저장된 앱을 띄우고 시작한다.
    final testApp = await pumpTestApp(
      tester,
      intervalSeconds: _intervalSeconds,
    );
    await scrollAndTap(tester, find.text('시작'));

    // 실행 1: 준비 10초가 끝나는 순간 소리와 함께 1배를 시작한다.
    await advanceSeconds(tester, CounterRules.preparationSeconds);
    expect(find.text('1'), findsOneWidget);
    expect(testApp.feedbackService.calls, hasLength(1));

    // 실행 2: 107번의 간격이 지나면 108배째를 시작하고, 아직 진행 중이다.
    await advanceIntervals(tester, CounterRules.targetBowCount - 1);
    expect(find.text('108'), findsOneWidget);
    expect(find.text('마지막 절 · 5초 후 완료'), findsOneWidget);
    expect(find.text('108배를 모두 마쳤습니다'), findsNothing);
    expect(testApp.wakeLockService.isEnabled, isTrue);

    // 실행 3: 108배째 간격이 끝나면 긴 소리와 함께 완료되고 화면 켜짐이 해제된다.
    await advanceIntervals(tester, 1);
    expect(find.text('108배를 모두 마쳤습니다'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isFalse);
    expect(testApp.feedbackService.calls.last.isFinalBow, isTrue);
    expect(
      testApp.feedbackService.calls,
      hasLength(CounterRules.targetBowCount + 1),
    );

    // 실행 4: 잠시 뒤 회향 화면이 열리고, 메모를 써서 저장한다.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('108배 회향'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '마음이 고요했다');
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증 1: 메인으로 돌아와 0배로 초기화되고 저장 안내가 뜬다.
    expect(find.text('기록을 저장했습니다'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // 실행 5: 수행 기록 화면을 연다.
    await tester.tap(find.byTooltip('수행 기록'));
    await tester.pumpAndSettle();

    // 검증 2: 이번 달 1회·108절, 연속 1일, 메모가 보인다.
    expect(find.text('1회'), findsOneWidget);
    expect(find.text('108절'), findsOneWidget);
    expect(find.text('1일'), findsNWidgets(2));
    expect(find.text('마음이 고요했다'), findsOneWidget);
    expect(testApp.repository.loadSessions(), hasLength(1));
  });

  testWidgets('startStopReset_flow_keepsCountOnStopAndClearsOnReset', (
    tester,
  ) async {
    // 준비: 5초 간격이 저장된 앱을 띄운다.
    final testApp = await pumpTestApp(
      tester,
      intervalSeconds: _intervalSeconds,
    );

    // 실행 1: 시작하면 10초 준비 카운트다운이 나온다.
    await scrollAndTap(tester, find.text('시작'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    expect(find.text('준비'), findsOneWidget);
    await advanceSeconds(tester, 1);
    expect(find.text('9'), findsOneWidget);

    // 실행 2: 준비가 끝나는 순간 소리와 함께 1배, 5초 뒤 2배가 된다.
    await advanceSeconds(tester, CounterRules.preparationSeconds - 1);
    expect(find.text('준비'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(testApp.feedbackService.calls, hasLength(1));
    expect(find.text('다음 절까지 5초'), findsOneWidget);
    await advanceIntervals(tester, 1);
    expect(find.text('2'), findsOneWidget);

    // 실행 3: 정지하면 시간이 흘러도 2배에서 멈춘다.
    await tester.tap(find.text('정지'));
    await tester.pump();
    await advanceSeconds(tester, 20);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('정지됨 · 시작을 누르면 이어서 셉니다'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isTrue);

    // 실행 4: 다시 시작하면 준비 없이 이어서 5초 뒤 3배가 된다.
    await tester.tap(find.text('시작'));
    await tester.pump();
    expect(find.text('준비'), findsNothing);
    await advanceIntervals(tester, 1);
    expect(find.text('3'), findsOneWidget);

    // 실행 5: 정지 후 처음부터를 확인하면 0배로 돌아간다.
    await tester.tap(find.text('정지'));
    await tester.pump();
    await tester.tap(find.text('처음부터'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 검증: 초기화되고 화면 켜짐이 해제된다.
    expect(find.text('0'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isFalse);
  });

  testWidgets('settingsAndCalendar_fullFlow_persistsAfterRelaunch', (
    tester,
  ) async {
    // 준비: 앱을 띄우고 설정을 연다.
    final testApp = await pumpTestApp(tester);
    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();

    // 실행 1: 네이비 배경·딥 블루 버튼색을 고르고 캘린더 기록을 켠다.
    await scrollAndTap(tester, find.text('네이비'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('딥 블루'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(testGoogleCalendar.name));
    await tester.pumpAndSettle();

    // 실행 2: 메인으로 돌아와 108배를 마치고 저장한다.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await runPracticeToCompletion(tester);
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증 1: 캘린더에도 추가되었다는 안내와 일정이 남는다.
    expect(find.text('기록을 저장하고 캘린더에 추가했습니다'), findsOneWidget);
    expect(testApp.calendarSyncService.addedEvents, hasLength(1));
    expect(
      testApp.calendarSyncService.addedEvents.single.calendar.id,
      testGoogleCalendar.id,
    );

    // 실행 3: 앱을 다시 실행한다(저장소 유지).
    await pumpTestApp(tester, resetPreferences: false);

    // 검증 2: 배경색·버튼색과 기록이 그대로 남아 있다.
    final theme = Theme.of(tester.element(find.byType(Scaffold).first));
    expect(
      theme.scaffoldBackgroundColor,
      SurfacePalette.of(BackgroundPreset.navy).background,
    );
    expect(
      theme.colorScheme.primary,
      AccentPalette.of(AccentPreset.deepBlue).accent,
    );
    await tester.tap(find.byTooltip('수행 기록'));
    await tester.pumpAndSettle();
    expect(find.text('1회'), findsOneWidget);
  });
}
