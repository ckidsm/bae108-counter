import 'dart:convert';

import 'package:bae108_counter/app.dart';
import 'package:bae108_counter/controllers/app_settings_controller.dart';
import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/models/counter_settings.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_services.dart';

/// 일반 휴대폰(iPhone 14/15) 세로 논리 크기.
const Size phoneSize = Size(390, 844);

/// 작은 휴대폰(iPhone SE) 세로 논리 크기.
const Size smallPhoneSize = Size(375, 667);

/// Android 휴대폰(Pixel 7) 세로 논리 크기.
const Size androidPhoneSize = Size(412, 915);

/// iPad Pro 11인치 가로 논리 크기.
const Size iPadLandscapeSize = Size(1194, 834);

/// iPad 10.2인치 가로 논리 크기.
const Size smallIPadLandscapeSize = Size(1080, 810);

/// Android 10인치 태블릿 가로 논리 크기.
const Size androidTabletLandscapeSize = Size(1280, 800);

/// Android 7~8인치 태블릿 가로 논리 크기(3단 화면 최소 폭 근처).
const Size smallAndroidTabletLandscapeSize = Size(960, 600);

// 테스트 화면 배율
const double _testPixelRatio = 2;

/// 테스트에서 쓰는 Google 계정 캘린더.
const CalendarTarget testGoogleCalendar = CalendarTarget(
  id: 'calendar-1',
  name: '내 캘린더',
  accountName: 'tester@gmail.com',
);

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Exposes the fakes and stores behind an app started for a test.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 테스트용으로 띄운 앱과 그 뒤의 가짜 서비스·저장소.
class TestApp {
  /// Creates the handle.
  const TestApp({
    required this.repository,
    required this.appSettingsController,
    required this.feedbackService,
    required this.wakeLockService,
    required this.calendarSyncService,
    required this.watchSyncService,
  });

  /// The record store backed by in-memory preferences.
  final PracticeRecordRepository repository;

  /// The app settings controller.
  final AppSettingsController appSettingsController;

  /// The fake bell/vibration service.
  final FakeBowFeedbackService feedbackService;

  /// The fake wake lock.
  final FakeWakeLockService wakeLockService;

  /// The fake calendar.
  final FakeCalendarSyncService calendarSyncService;

  /// The fake Apple Watch bridge.
  final FakeWatchSyncService watchSyncService;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Starts the whole app on a phone-sized screen with fake device services.
 Remarks  : Keep resetPreferences false to simulate relaunching with stored data.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 가짜 기기 서비스로 앱 전체를 휴대폰 크기 화면에 띄운다.
Future<TestApp> pumpTestApp(
  WidgetTester tester, {
  Locale locale = const Locale('ko'),
  bool resetPreferences = true,
  int? intervalSeconds,
  FakeCalendarSyncService? calendarSyncService,
  FakeWatchSyncService? watchSyncService,
  Size logicalSize = phoneSize,
}) async {
  // 지정한 논리 크기 화면으로 맞춘다.
  tester.view.physicalSize = logicalSize * _testPixelRatio;
  // 화면 배율
  tester.view.devicePixelRatio = _testPixelRatio;
  // 테스트가 끝나면 화면 크기를 되돌린다.
  addTearDown(tester.view.reset);
  // 기기 언어를 지정한다.
  tester.platformDispatcher.localesTestValue = <Locale>[locale];
  // 테스트가 끝나면 기기 언어를 되돌린다.
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // 처음 실행이면 저장소를 비운다(재실행 흉내는 유지).
  if (resetPreferences) {
    // 메모리 저장소(간격을 지정했으면 저장된 설정으로 넣어 둔다)
    SharedPreferences.setMockInitialValues(<String, Object>{
      if (intervalSeconds != null)
        PreferenceKeys.counterSettings: jsonEncode(
          CounterSettings(
            intervalSeconds: intervalSeconds,
            alertMode: AlertMode.bell,
          ).toJson(),
        ),
    });
  }
  // 이전에 띄운 앱 상태가 재사용되지 않도록 화면을 비운다(앱 재실행 흉내).
  await tester.pumpWidget(const SizedBox.shrink());
  // 저장소 인스턴스
  final preferences = await SharedPreferences.getInstance();
  // 기록 저장소
  final repository = PracticeRecordRepository(preferences);
  // 테스트 앱 구성
  final testApp = TestApp(
    repository: repository,
    appSettingsController: AppSettingsController(repository),
    feedbackService: FakeBowFeedbackService(),
    wakeLockService: FakeWakeLockService(),
    calendarSyncService:
        calendarSyncService ??
        FakeCalendarSyncService(
          calendars: <CalendarTarget>[testGoogleCalendar],
        ),
    watchSyncService: watchSyncService ?? FakeWatchSyncService(),
  );
  // 앱을 그린다.
  await tester.pumpWidget(
    Bae108App(
      repository: testApp.repository,
      feedbackService: testApp.feedbackService,
      wakeLockService: testApp.wakeLockService,
      appSettingsController: testApp.appSettingsController,
      calendarSyncService: testApp.calendarSyncService,
      watchSyncService: testApp.watchSyncService,
    ),
  );
  // 번역 로딩을 기다린다.
  await tester.pumpAndSettle();
  // 확인용으로 돌려준다.
  return testApp;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Scrolls a widget into view and taps it.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 위젯이 보이도록 스크롤한 뒤 탭한다.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  // 화면에 보이게 스크롤한다.
  await scrollTo(tester, finder);
  // 스크롤이 끝날 때까지 그린다.
  await tester.pumpAndSettle();
  // 탭한다.
  await tester.tap(finder);
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Advances fake time second by second so the counter timer runs.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 가짜 시간을 1초씩 [seconds]초 진행하며 매초 화면을 그린다.
Future<void> advanceSeconds(WidgetTester tester, int seconds) async {
  // 1초씩 진행한다.
  for (var secondIndex = 0; secondIndex < seconds; secondIndex++) {
    // 1초 진행
    await tester.pump(const Duration(seconds: 1));
  }
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Starts a practice and advances fake time until the completion screen opens.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 현재 간격([intervalSeconds])으로 시작해 108배를 마치고 회향 화면이 열릴 때까지 진행한다.
Future<void> runPracticeToCompletion(
  WidgetTester tester, {
  int intervalSeconds = CounterRules.defaultIntervalSeconds,
}) async {
  // 시작한다.
  await scrollAndTap(tester, find.text('시작'));
  // 준비 시간을 진행한다.
  await tester.pump(const Duration(seconds: CounterRules.preparationSeconds));
  // 108배 + 1회(마지막 절을 확실히 넘기도록) 간격만큼 진행한다.
  for (var bowIndex = 0; bowIndex <= CounterRules.targetBowCount; bowIndex++) {
    // 간격 하나 진행
    await tester.pump(Duration(seconds: intervalSeconds));
  }
  // 완료 후 회향 화면이 열리기까지(1.5초) 기다린다.
  await tester.pump(const Duration(seconds: 2));
  // 화면 전환을 마친다.
  await tester.pumpAndSettle();
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Scrolls the top screen until a widget is built and visible.
 Remarks  : ListView builds only nearby items, so items far below must be
            scrolled into existence before ensureVisible can find them.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 맨 위 화면을 스크롤해 [finder] 위젯이 만들어지고 보이게 한다.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  // 아직 만들어지지 않았으면 아래로 내려가며 찾는다.
  if (finder.evaluate().isEmpty) {
    // 맨 위 화면의 스크롤 영역을 조금씩 내린다.
    await tester.scrollUntilVisible(
      finder,
      _scrollStepPixels,
      scrollable: find.byType(Scrollable).last,
    );
  }
  // 화면 안으로 완전히 들어오게 맞춘다.
  await tester.ensureVisible(finder);
  // 스크롤이 끝날 때까지 그린다.
  await tester.pumpAndSettle();
}

// 한 번에 스크롤할 거리(논리 픽셀)
const double _scrollStepPixels = 200;
