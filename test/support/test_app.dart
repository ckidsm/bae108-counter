import 'package:bae108_counter/app.dart';
import 'package:bae108_counter/controllers/app_settings_controller.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_services.dart';

// 테스트 화면 크기: 390x844 논리 픽셀(일반 휴대폰)
const Size _phonePhysicalSize = Size(1170, 2532);
// 테스트 화면 배율
const double _phonePixelRatio = 3;

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
  FakeCalendarSyncService? calendarSyncService,
}) async {
  // 휴대폰 크기 화면으로 맞춘다.
  tester.view.physicalSize = _phonePhysicalSize;
  // 화면 배율
  tester.view.devicePixelRatio = _phonePixelRatio;
  // 테스트가 끝나면 화면 크기를 되돌린다.
  addTearDown(tester.view.reset);
  // 기기 언어를 지정한다.
  tester.platformDispatcher.localesTestValue = <Locale>[locale];
  // 테스트가 끝나면 기기 언어를 되돌린다.
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // 처음 실행이면 저장소를 비운다(재실행 흉내는 유지).
  if (resetPreferences) {
    // 비어 있는 메모리 저장소
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
  );
  // 앱을 그린다.
  await tester.pumpWidget(
    Bae108App(
      repository: testApp.repository,
      feedbackService: testApp.feedbackService,
      wakeLockService: testApp.wakeLockService,
      appSettingsController: testApp.appSettingsController,
      calendarSyncService: testApp.calendarSyncService,
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
  await tester.ensureVisible(finder);
  // 스크롤이 끝날 때까지 그린다.
  await tester.pumpAndSettle();
  // 탭한다.
  await tester.tap(finder);
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Taps the counter circle the given number of times.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 원형 카운터를 [tapCount]번 탭한다.
Future<void> tapCounterRing(WidgetTester tester, int tapCount) async {
  // 원 가운데 "/ 108" 글자를 기준으로 탭한다.
  final ringFinder = find.text('/ 108');
  // 정해진 횟수만큼 탭한다.
  for (var tapIndex = 0; tapIndex < tapCount; tapIndex++) {
    // 원을 탭한다.
    await tester.tap(ringFinder);
    // 한 프레임 그린다.
    await tester.pump();
  }
}
