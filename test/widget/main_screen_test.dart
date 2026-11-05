import 'package:bae108_counter/widgets/ascetic_emblem.dart';
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

  testWidgets('mainScreen_layout_hasNoCountModeSelectorOrDecrement', (
    tester,
  ) async {
    // 준비 및 실행: 앱을 띄운다.
    await pumpTestApp(tester);

    // 검증: 카운트 방식 선택과 [−] 버튼이 없고 간격 칩과 엠블럼이 있다.
    expect(find.text('직접 탭'), findsNothing);
    expect(find.text('자동 간격'), findsNothing);
    expect(find.byIcon(Icons.remove), findsNothing);
    expect(find.text('5초'), findsOneWidget);
    expect(find.text('직접 설정'), findsOneWidget);
    expect(find.byType(AsceticEmblem), findsOneWidget);
  });

  testWidgets('controls_idle_enablesStartAndDisablesStop', (tester) async {
    // 준비 및 실행: 앱을 띄운다.
    await pumpTestApp(tester);

    // 검증: 시작만 누를 수 있다.
    expect(isButtonEnabled(tester, '시작'), isTrue);
    expect(isButtonEnabled(tester, '정지'), isFalse);
    expect(isButtonEnabled(tester, '처음부터'), isFalse);
  });

  testWidgets('startButton_pressed_showsCountdownAndEnablesStop', (
    tester,
  ) async {
    // 준비: 앱을 띄운다.
    final testApp = await pumpTestApp(tester);

    // 실행: 시작을 누른다.
    await scrollAndTap(tester, find.text('시작'));
    await tester.pump();

    // 검증: 10초 준비가 나오고 시작은 막히고 정지는 눌린다.
    expect(find.text('10'), findsOneWidget);
    expect(find.text('준비'), findsOneWidget);
    expect(isButtonEnabled(tester, '시작'), isFalse);
    expect(isButtonEnabled(tester, '정지'), isTrue);
    expect(testApp.wakeLockService.isEnabled, isTrue);

    // 정리: 정지해서 타이머를 멈춘다.
    await tester.tap(find.text('정지'));
    await tester.pump();
  });

  testWidgets('counterRing_tapped_doesNotCount', (tester) async {
    // 준비: 앱을 띄운다.
    await pumpTestApp(tester);

    // 실행: 원을 탭한다.
    await tester.tap(find.text('/ 108'));
    await tester.pump();

    // 검증: 0배 그대로이고 시작되지 않는다.
    expect(find.text('0'), findsOneWidget);
    expect(isButtonEnabled(tester, '정지'), isFalse);
  });

  testWidgets('resetButton_afterStop_asksConfirmationBeforeClearing', (
    tester,
  ) async {
    // 준비: 5초 간격으로 시작해 1배를 센 뒤 정지한다.
    await pumpTestApp(tester);
    await scrollAndTap(tester, find.text('5초'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('시작'));
    await advanceSeconds(tester, 15);
    await tester.tap(find.text('정지'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // 실행: 처음부터 → 확인을 누른다.
    await tester.tap(find.text('처음부터'));
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

// 해당 문구가 들어 있는 버튼이 눌릴 수 있는 상태인지 확인한다.
bool isButtonEnabled(WidgetTester tester, String label) {
  // 문구를 감싸는 가장 가까운 버튼
  final button = tester.widget<ButtonStyleButton>(
    find
        .ancestor(
          of: find.text(label),
          matching: find.bySubtype<ButtonStyleButton>(),
        )
        .first,
  );
  // onPressed가 있으면 누를 수 있다.
  return button.onPressed != null;
}
