import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/accent_preset.dart';
import 'package:bae108_counter/models/background_preset.dart';
import 'package:bae108_counter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// 108배째 이후 회향 화면이 열리기까지 기다리는 시간(앱의 1.5초 지연보다 길게)
const Duration _completionScreenWait = Duration(milliseconds: 1600);

// 화면이 바뀌지 않는 1초를 진행한다(자동 모드 타이머 진행용).
Future<void> advanceSeconds(WidgetTester tester, int seconds) async {
  // 1초씩 진행해 매초 화면을 그린다.
  for (var secondIndex = 0; secondIndex < seconds; secondIndex++) {
    // 1초 진행
    await tester.pump(const Duration(seconds: 1));
  }
}

// 108배를 탭으로 마치고 회향 화면이 열릴 때까지 기다린다.
Future<void> completePracticeByTapping(WidgetTester tester) async {
  // 108번 탭한다.
  await tapCounterRing(tester, CounterRules.targetBowCount);
  // 녹색 완료 링을 보여 주는 동안 기다린다.
  await tester.pump(_completionScreenWait);
  // 화면 전환을 마친다.
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapPractice_fullFlow_savesRecordAndShowsItInHistory', (
    tester,
  ) async {
    // 준비: 앱을 띄운다.
    final testApp = await pumpTestApp(tester);

    // 실행 1: 107배까지 탭하면 아직 진행 중이다.
    await tapCounterRing(tester, CounterRules.targetBowCount - 1);
    expect(find.text('107'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isTrue);

    // 실행 2: 108배째를 탭하면 완료되고 화면 켜짐이 해제된다.
    await tapCounterRing(tester, 1);
    expect(find.text('108배를 모두 마쳤습니다'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isFalse);
    expect(testApp.feedbackService.calls.last.isFinalBow, isTrue);

    // 실행 3: 잠시 뒤 회향 화면이 열리고, 메모를 써서 저장한다.
    await tester.pump(_completionScreenWait);
    await tester.pumpAndSettle();
    expect(find.text('108배 회향'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '마음이 고요했다');
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증 1: 메인으로 돌아와 0배로 초기화되고 저장 안내가 뜬다.
    expect(find.text('기록을 저장했습니다'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // 실행 4: 수행 기록 화면을 연다.
    await tester.tap(find.byTooltip('수행 기록'));
    await tester.pumpAndSettle();

    // 검증 2: 연속 1일, 이번 달 1회·108절, 메모가 보인다.
    expect(find.text('수행 기록'), findsOneWidget);
    expect(find.text('1회'), findsOneWidget);
    expect(find.text('108절'), findsOneWidget);
    expect(find.text('1일'), findsNWidgets(2));
    expect(find.text('마음이 고요했다'), findsOneWidget);
    expect(testApp.repository.loadSessions(), hasLength(1));
  });

  testWidgets('autoPractice_countdownPauseResumeReset_flow', (tester) async {
    // 준비: 자동 간격 5초를 고른다.
    final testApp = await pumpTestApp(tester);
    await tester.tap(find.text('자동 간격'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5초'));
    await tester.pumpAndSettle();

    // 실행 1: 시작하면 10초 준비 카운트다운이 나온다.
    await scrollAndTap(tester, find.text('시작'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    expect(find.text('준비'), findsOneWidget);
    await advanceSeconds(tester, 1);
    expect(find.text('9'), findsOneWidget);

    // 실행 2: 준비가 끝나면 0배부터 세고, 5초 뒤 1배가 된다.
    await advanceSeconds(tester, CounterRules.preparationSeconds - 1);
    expect(find.text('준비'), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('다음 절까지 5초'), findsOneWidget);
    await advanceSeconds(tester, 5);
    expect(find.text('1'), findsOneWidget);
    expect(testApp.feedbackService.calls, hasLength(1));

    // 실행 3: 일시정지하면 시간이 흘러도 세지 않는다.
    await tester.tap(find.text('일시정지'));
    await tester.pump();
    await advanceSeconds(tester, 20);
    expect(find.text('1'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isTrue);

    // 실행 4: 이어서 하면 준비 없이 5초 뒤 2배가 된다.
    await tester.tap(find.text('이어서'));
    await tester.pump();
    expect(find.text('준비'), findsNothing);
    await advanceSeconds(tester, 5);
    expect(find.text('2'), findsOneWidget);

    // 실행 5: 원을 탭하면 즉시 3배가 되고 간격이 다시 시작된다.
    await tapCounterRing(tester, 1);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('다음 절까지 5초'), findsOneWidget);

    // 실행 6: 일시정지 후 처음부터를 확인하면 0배로 돌아간다.
    await tester.tap(find.text('일시정지'));
    await tester.pump();
    await tester.tap(find.text('처음부터'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 검증: 초기화되고 화면 켜짐이 해제된다.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('시작'), findsOneWidget);
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
    await tester.tap(find.text('네이비'));
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
    await completePracticeByTapping(tester);
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
