import 'package:bae108_counter/models/app_settings.dart';
import 'package:bae108_counter/models/bow_session.dart';
import 'package:bae108_counter/screens/completion_screen.dart';
import 'package:bae108_counter/l10n/generated/app_localizations.dart';
import 'package:bae108_counter/services/calendar_sync_service.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_services.dart';
import '../support/test_app.dart';

// 회향 화면에 넘길 완료 기록(14:02~14:40, 38분 12초)
final BowSession _completedSession = BowSession(
  id: 'session-1',
  startedAt: DateTime(2026, 11, 4, 14, 2),
  endedAt: DateTime(2026, 11, 4, 14, 40),
  activeDurationSeconds: 2292,
  bowCount: 108,
);

void main() {
  // 회향 화면을 띄우고 닫힌 결과를 돌려받을 수 있게 한다.
  Future<
    ({PracticeRecordRepository repository, List<CompletionOutcome?> outcomes})
  >
  pumpCompletion(
    WidgetTester tester, {
    required AppSettings appSettings,
    required FakeCalendarSyncService calendarSyncService,
  }) async {
    // 휴대폰 크기 화면
    tester.view.physicalSize = const Size(1170, 2532);
    // 화면 배율
    tester.view.devicePixelRatio = 3;
    // 끝나면 되돌린다.
    addTearDown(tester.view.reset);
    // 빈 저장소
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // 기록 저장소
    final repository = PracticeRecordRepository(
      await SharedPreferences.getInstance(),
    );
    // 회향 화면이 돌려준 결과
    final outcomes = <CompletionOutcome?>[];
    // 버튼으로 회향 화면을 여는 시작 화면
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              outcomes.add(
                await Navigator.of(context).push<CompletionOutcome>(
                  MaterialPageRoute<CompletionOutcome>(
                    builder: (_) => CompletionScreen(
                      session: _completedSession,
                      repository: repository,
                      appSettings: appSettings,
                      calendarSyncService: calendarSyncService,
                    ),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    // 회향 화면을 연다.
    await tester.tap(find.text('open'));
    // 전환을 기다린다.
    await tester.pumpAndSettle();
    // 확인용으로 돌려준다.
    return (repository: repository, outcomes: outcomes);
  }

  testWidgets('completionScreen_opened_showsSummary', (tester) async {
    // 준비 및 실행: 회향 화면을 연다.
    await pumpCompletion(
      tester,
      appSettings: const AppSettings(),
      calendarSyncService: FakeCalendarSyncService(),
    );

    // 검증: 제목, 소요 시간, 1배 평균, 연속 일수, 시작→종료 시각
    expect(find.text('108배 회향'), findsOneWidget);
    expect(find.text('38분 12초'), findsOneWidget);
    expect(find.text('21.2초'), findsOneWidget);
    expect(find.text('1일'), findsOneWidget);
    expect(find.text('14:02 → 14:40'), findsOneWidget);
  });

  testWidgets('saveRecord_calendarOff_savesWithMemoOnly', (tester) async {
    // 준비: 캘린더 기록이 꺼진 회향 화면
    final calendarSyncService = FakeCalendarSyncService();
    final result = await pumpCompletion(
      tester,
      appSettings: const AppSettings(),
      calendarSyncService: calendarSyncService,
    );

    // 실행: 메모를 쓰고 저장한다.
    await tester.enterText(find.byType(TextField), '  마음이 고요했다  ');
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증: 메모가 다듬어져 저장되고 캘린더에는 추가되지 않는다.
    expect(result.repository.loadSessions().single.memo, '마음이 고요했다');
    expect(calendarSyncService.addedEvents, isEmpty);
    expect(result.outcomes.single, CompletionOutcome.saved);
  });

  testWidgets('saveRecord_calendarOn_addsEventWithMemo', (tester) async {
    // 준비: 캘린더 기록이 켜진 회향 화면
    final calendarSyncService = FakeCalendarSyncService();
    final result = await pumpCompletion(
      tester,
      appSettings: const AppSettings(
        isCalendarSyncEnabled: true,
        calendarTarget: testGoogleCalendar,
      ),
      calendarSyncService: calendarSyncService,
    );

    // 실행: 메모를 쓰고 저장한다.
    await tester.enterText(find.byType(TextField), '마음이 고요했다');
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증: 선택한 캘린더에 시각·제목·메모가 담긴 일정이 추가된다.
    final addedEvent = calendarSyncService.addedEvents.single;
    expect(addedEvent.calendar.id, testGoogleCalendar.id);
    expect(addedEvent.session.startedAt, _completedSession.startedAt);
    expect(addedEvent.session.endedAt, _completedSession.endedAt);
    expect(addedEvent.text.title, '108배 수행');
    expect(addedEvent.text.description, '108배 · 소요 시간 38분 12초\n마음이 고요했다');
    expect(result.outcomes.single, CompletionOutcome.savedToCalendar);
  });

  testWidgets('saveRecord_calendarFails_keepsRecordAndReportsFailure', (
    tester,
  ) async {
    // 준비: 일정 추가가 실패하는 캘린더
    final calendarSyncService = FakeCalendarSyncService()
      ..failure = CalendarSyncFailure.platformError;
    final result = await pumpCompletion(
      tester,
      appSettings: const AppSettings(
        isCalendarSyncEnabled: true,
        calendarTarget: testGoogleCalendar,
      ),
      calendarSyncService: calendarSyncService,
    );

    // 실행: 저장한다.
    await tester.tap(find.text('기록 저장'));
    await tester.pumpAndSettle();

    // 검증: 기록은 남고 캘린더 실패가 보고된다.
    expect(result.repository.loadSessions(), hasLength(1));
    expect(result.outcomes.single, CompletionOutcome.savedCalendarFailed);
  });

  testWidgets('restartPractice_confirmed_closesWithoutSaving', (tester) async {
    // 준비: 회향 화면
    final result = await pumpCompletion(
      tester,
      appSettings: const AppSettings(),
      calendarSyncService: FakeCalendarSyncService(),
    );

    // 실행: 한 번 더 하기 → 저장 안 함
    await tester.tap(find.text('한 번 더 하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장 안 함'));
    await tester.pumpAndSettle();

    // 검증: 저장되지 않고 다시 시작 결과로 닫힌다.
    expect(result.repository.loadSessions(), isEmpty);
    expect(result.outcomes.single, CompletionOutcome.restarted);
  });
}
