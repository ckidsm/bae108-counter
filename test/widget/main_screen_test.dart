import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('mainScreen_initialLoad_showsTitleAndZeroCount', (tester) async {
    // 준비 및 실행: 앱을 띄운다.
    await pumpTestApp(tester);

    // 검증: 제목, 화면 켜짐 안내, 0 / 108이 보인다.
    expect(find.text('오늘의 108배'), findsOneWidget);
    expect(find.text('108배까지 화면 켜짐 유지'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 108'), findsOneWidget);
  });

  testWidgets('mainScreen_header_showsHistoryThenSettingsIcons', (
    tester,
  ) async {
    // 준비 및 실행: 앱을 띄운다.
    await pumpTestApp(tester);

    // 검증: 설정 아이콘이 달력 아이콘 오른쪽에 있다.
    final historyIcon = tester.getCenter(find.byTooltip('수행 기록'));
    final settingsIcon = tester.getCenter(find.byTooltip('설정'));
    expect(settingsIcon.dx, greaterThan(historyIcon.dx));
  });

  testWidgets('mainScreen_controls_hasNoDecrementButton', (tester) async {
    // 준비 및 실행: 앱을 띄운다.
    await pumpTestApp(tester);

    // 검증: [−] 버튼이 없다.
    expect(find.byIcon(Icons.remove), findsNothing);
  });

  testWidgets('counterRing_tapped_incrementsCountAndKeepsScreenOn', (
    tester,
  ) async {
    // 준비: 앱을 띄운다.
    final testApp = await pumpTestApp(tester);

    // 실행: 원을 탭한다.
    await tapCounterRing(tester, 1);

    // 검증: 1배가 되고 화면 켜짐이 유지된다.
    expect(find.text('1'), findsOneWidget);
    expect(testApp.wakeLockService.isEnabled, isTrue);
  });

  testWidgets('countModeAuto_selected_showsIntervalChips', (tester) async {
    // 준비: 앱을 띄운다.
    await pumpTestApp(tester);

    // 실행: 자동 간격을 고른다.
    await tester.tap(find.text('자동 간격'));
    await tester.pumpAndSettle();

    // 검증: 간격 칩이 보인다.
    expect(find.text('5초'), findsOneWidget);
    expect(find.text('10초'), findsOneWidget);
    expect(find.text('20초'), findsOneWidget);
    expect(find.text('직접 설정'), findsOneWidget);
  });

  testWidgets('resetButton_withCountedBows_asksConfirmationBeforeClearing', (
    tester,
  ) async {
    // 준비: 3배를 센다.
    await pumpTestApp(tester);
    await tapCounterRing(tester, 3);

    // 실행: 처음부터 → 확인을 누른다.
    await scrollAndTap(tester, find.text('처음부터'));
    await tester.pumpAndSettle();
    expect(find.text('처음부터 다시 할까요?'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 검증: 0배로 돌아간다.
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('mainScreen_supportedLocales_showsTranslatedTitle', (
    tester,
  ) async {
    // 준비: 언어별 기대 제목
    const expectedTitles = <String, String>{
      'en': "Today's 108 Bows",
      'ja': '今日の108拝',
      'zh': '今日108拜',
      'ko': '오늘의 108배',
    };

    // 실행 및 검증: 언어마다 앱을 띄워 제목을 확인한다.
    for (final entry in expectedTitles.entries) {
      await pumpTestApp(tester, locale: Locale(entry.key));
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('mainScreen_unsupportedLocale_fallsBackToEnglish', (
    tester,
  ) async {
    // 준비 및 실행: 지원하지 않는 프랑스어로 띄운다.
    await pumpTestApp(tester, locale: const Locale('fr'));

    // 검증: 영어로 표시된다.
    expect(find.text("Today's 108 Bows"), findsOneWidget);
  });
}
