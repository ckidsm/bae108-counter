import 'package:bae108_counter/app.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_services.dart';

void main() {
  // 가짜 서비스로 앱 전체를 띄운다.
  Future<FakeWakeLockService> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('ko'),
  }) async {
    // 기기 언어를 지정한다(기본은 한국어).
    tester.platformDispatcher.localesTestValue = <Locale>[locale];
    // 테스트가 끝나면 기기 언어를 되돌린다.
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    // 비어 있는 메모리 저장소
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // 저장소 인스턴스
    final preferences = await SharedPreferences.getInstance();
    // 휴대폰 크기(390x844 논리 픽셀) 화면으로 맞춘다.
    tester.view.physicalSize = const Size(1170, 2532);
    // 화면 배율 3배
    tester.view.devicePixelRatio = 3;
    // 테스트가 끝나면 화면 크기를 되돌린다.
    addTearDown(tester.view.reset);
    // 가짜 화면 켜짐 서비스
    final wakeLockService = FakeWakeLockService();
    // 앱을 그린다.
    await tester.pumpWidget(
      Bae108App(
        repository: PracticeRecordRepository(preferences),
        feedbackService: FakeBowFeedbackService(),
        wakeLockService: wakeLockService,
      ),
    );
    // 번역 로딩을 기다린다.
    await tester.pump();
    // 확인용으로 돌려준다.
    return wakeLockService;
  }

  testWidgets('mainScreen_initialLoad_showsTitleAndZeroCount', (tester) async {
    // 준비 및 실행: 대상을 만들고 동작을 수행한다.
    await pumpApp(tester);

    // 검증: 기대 결과를 확인한다.
    expect(find.text('오늘의 108배'), findsOneWidget);
    expect(find.text('108배까지 화면 켜짐 유지'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 108'), findsOneWidget);
  });

  testWidgets('counterRing_tapped_incrementsCountAndKeepsScreenOn', (
    tester,
  ) async {
    // 준비: 테스트 조건을 만든다.
    final wakeLockService = await pumpApp(tester);

    // 실행: 테스트 대상 동작을 수행한다.
    await tester.tap(find.text('/ 108'));
    await tester.pump();

    // 검증: 기대 결과를 확인한다.
    expect(find.text('1'), findsOneWidget);
    expect(wakeLockService.isEnabled, isTrue);
  });

  testWidgets('countModeAuto_selected_showsIntervalChips', (tester) async {
    // 준비: 테스트 조건을 만든다.
    await pumpApp(tester);

    // 실행: 테스트 대상 동작을 수행한다.
    await tester.tap(find.text('자동 간격'));
    await tester.pumpAndSettle();

    // 검증: 기대 결과를 확인한다.
    expect(find.text('5초'), findsOneWidget);
    expect(find.text('10초'), findsOneWidget);
    expect(find.text('20초'), findsOneWidget);
    expect(find.text('직접 설정'), findsOneWidget);
  });

  testWidgets('startButton_autoMode_showsPreparationCountdown', (tester) async {
    // 준비: 테스트 조건을 만든다.
    await pumpApp(tester);
    await tester.tap(find.text('자동 간격'));
    await tester.pumpAndSettle();

    // 준비: 테스트 조건을 만든다.
    await tester.ensureVisible(find.text('시작'));
    await tester.tap(find.text('시작'));
    await tester.pump();

    // 실행: 테스트 대상 동작을 수행한다.
    expect(find.text('10'), findsOneWidget);
    expect(find.text('준비'), findsOneWidget);

    // 검증: 기대 결과를 확인한다.
    await tester.ensureVisible(find.text('일시정지'));
    await tester.tap(find.text('일시정지'));
    await tester.pump();
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
      await pumpApp(tester, locale: Locale(entry.key));
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('mainScreen_unsupportedLocale_fallsBackToEnglish', (
    tester,
  ) async {
    // 준비 및 실행: 지원하지 않는 프랑스어로 띄운다.
    await pumpApp(tester, locale: const Locale('fr'));

    // 검증: 영어로 표시된다.
    expect(find.text("Today's 108 Bows"), findsOneWidget);
  });
}
