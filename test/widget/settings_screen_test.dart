import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/accent_preset.dart';
import 'package:bae108_counter/models/background_preset.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:bae108_counter/services/calendar_sync_service.dart';
import 'package:bae108_counter/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_services.dart';
import '../support/test_app.dart';

void main() {
  // 앱을 띄우고 설정 화면을 연다.
  Future<TestApp> openSettings(
    WidgetTester tester, {
    FakeCalendarSyncService? calendarSyncService,
  }) async {
    // 앱을 띄운다.
    final testApp = await pumpTestApp(
      tester,
      calendarSyncService: calendarSyncService,
    );
    // 설정 아이콘을 누른다.
    await tester.tap(find.byTooltip('설정'));
    // 화면 전환을 기다린다.
    await tester.pumpAndSettle();
    // 확인용으로 돌려준다.
    return testApp;
  }

  // 현재 화면 Scaffold의 배경색
  Color scaffoldBackgroundOf(WidgetTester tester) {
    // 가장 위 화면의 테마 배경색
    return Theme.of(tester.element(find.byType(Scaffold).last))
        .scaffoldBackgroundColor;
  }

  testWidgets('settingsScreen_opened_showsThreeSections', (tester) async {
    // 준비 및 실행: 설정 화면을 연다.
    await openSettings(tester);

    // 검증: 간격·테마·캘린더 항목이 보인다.
    expect(find.text('카운트 간격'), findsOneWidget);
    expect(find.text('색상 테마'), findsOneWidget);
    expect(find.text('배경색'), findsOneWidget);
    expect(find.text('버튼색'), findsOneWidget);
    expect(find.text('캘린더 기록'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('themeTile_navyTapped_changesBackgroundAndSaves', (tester) async {
    // 준비: 설정 화면을 연다.
    final testApp = await openSettings(tester);

    // 실행: 네이비를 고른다.
    await tester.tap(find.text('네이비'));
    await tester.pumpAndSettle();

    // 검증: 배경색이 바뀌고 저장된다.
    expect(
      scaffoldBackgroundOf(tester),
      SurfacePalette.of(BackgroundPreset.navy).background,
    );
    expect(
      testApp.repository.loadAppSettings().backgroundPreset,
      BackgroundPreset.navy,
    );
  });

  testWidgets('accentSwatch_blueTapped_changesButtonColorAndSaves', (
    tester,
  ) async {
    // 준비: 설정 화면을 연다.
    final testApp = await openSettings(tester);

    // 실행: 버튼색을 블루로 고른다.
    await scrollAndTap(tester, find.text('블루'));
    await tester.pumpAndSettle();

    // 검증: 테마의 버튼색이 #1976D2로 바뀌고 저장된다.
    final colorScheme = Theme.of(tester.element(find.byType(Scaffold).last))
        .colorScheme;
    expect(colorScheme.primary, AccentPalette.of(AccentPreset.blue).accent);
    expect(colorScheme.primary, const Color(0xFF1976D2));
    expect(
      testApp.repository.loadAppSettings().accentPreset,
      AccentPreset.blue,
    );
  });

  testWidgets('backgroundSwatch_whiteTapped_switchesToLightTheme', (
    tester,
  ) async {
    // 준비: 설정 화면을 연다.
    await openSettings(tester);

    // 실행: 배경색을 화이트로 고른다.
    await tester.tap(find.text('화이트'));
    await tester.pumpAndSettle();

    // 검증: 흰 배경의 밝은 테마가 되고 글자색은 어두워진다.
    final theme = Theme.of(tester.element(find.byType(Scaffold).last));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.onSurface.computeLuminance(), lessThan(0.2));
  });

  testWidgets('intervalSlider_dragged_changesIntervalAndSaves', (tester) async {
    // 준비: 설정 화면을 연다.
    final testApp = await openSettings(tester);

    // 실행: 슬라이더를 오른쪽 끝까지 끈다.
    await tester.drag(find.byType(Slider), const Offset(600, 0));
    await tester.pumpAndSettle();

    // 검증: 3분으로 바뀌고 저장된다.
    expect(find.text('3분'), findsWidgets);
    expect(
      testApp.repository
          .loadSettings(CounterRules.defaultSettings)
          .intervalSeconds,
      180,
    );
  });

  testWidgets('calendarSwitch_turnedOn_picksCalendarAndShowsIt', (
    tester,
  ) async {
    // 준비: 설정 화면을 연다.
    final testApp = await openSettings(tester);

    // 실행: 스위치를 켜고 캘린더를 고른다.
    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('캘린더 선택'), findsOneWidget);
    await tester.tap(find.text(testGoogleCalendar.name));
    await tester.pumpAndSettle();

    // 검증: 선택한 캘린더가 표시되고 저장된다.
    expect(
      find.text(
        '${testGoogleCalendar.name} (${testGoogleCalendar.accountName})',
      ),
      findsOneWidget,
    );
    final savedSettings = testApp.repository.loadAppSettings();
    expect(savedSettings.isCalendarSyncEnabled, isTrue);
    expect(savedSettings.calendarTarget?.id, testGoogleCalendar.id);
  });

  testWidgets('calendarSwitch_permissionDenied_showsPermissionMessage', (
    tester,
  ) async {
    // 준비: 권한이 거부되는 캘린더로 설정 화면을 연다.
    final calendarSyncService = FakeCalendarSyncService()
      ..failure = CalendarSyncFailure.permissionDenied;
    final testApp = await openSettings(
      tester,
      calendarSyncService: calendarSyncService,
    );

    // 실행: 스위치를 켠다.
    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();

    // 검증: 권한 안내가 뜨고 꺼진 상태로 남는다.
    expect(find.text('캘린더 권한이 없습니다. 기기 설정에서 캘린더 접근을 허용해 주세요'), findsOneWidget);
    expect(
      testApp.appSettingsController.settings.isCalendarSyncEnabled,
      isFalse,
    );
  });

  testWidgets('calendarSwitch_noWritableCalendars_showsEmptyMessage', (
    tester,
  ) async {
    // 준비: 캘린더가 없는 기기로 설정 화면을 연다.
    await openSettings(
      tester,
      calendarSyncService: FakeCalendarSyncService(
        calendars: const <CalendarTarget>[],
      ),
    );

    // 실행: 스위치를 켠다.
    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();

    // 검증: 캘린더 없음 안내가 뜬다.
    expect(
      find.text('쓸 수 있는 캘린더가 없습니다. 기기에 Google 계정이 추가되어 있는지 확인해 주세요'),
      findsOneWidget,
    );
  });

  testWidgets('calendarSwitch_turnedOff_disablesRecording', (tester) async {
    // 준비: 캘린더 기록을 켠다.
    final testApp = await openSettings(tester);
    testApp.appSettingsController.enableCalendarSync(testGoogleCalendar);
    await tester.pumpAndSettle();

    // 실행: 스위치를 끈다.
    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();

    // 검증: 꺼지고 캘린더 줄이 사라진다.
    expect(
      testApp.appSettingsController.settings.isCalendarSyncEnabled,
      isFalse,
    );
    expect(find.text('기록할 캘린더'), findsNothing);
  });
}
