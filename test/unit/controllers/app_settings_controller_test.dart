import 'package:bae108_counter/controllers/app_settings_controller.dart';
import 'package:bae108_counter/models/background_preset.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 테스트용 캘린더
const CalendarTarget _calendar = CalendarTarget(
  id: 'calendar-1',
  name: '내 캘린더',
  accountName: 'tester@gmail.com',
);

void main() {
  // 빈 저장소를 만든다.
  Future<PracticeRecordRepository> createRepository() async {
    // 메모리 기반 shared_preferences
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // 저장소
    return PracticeRecordRepository(await SharedPreferences.getInstance());
  }

  test('setBackgroundPreset_charcoal_notifiesAndPersists', () async {
    // 준비: 컨트롤러와 알림 횟수
    final repository = await createRepository();
    final controller = AppSettingsController(repository);
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    // 실행: 차콜로 바꾼다.
    controller.setBackgroundPreset(BackgroundPreset.charcoal);

    // 검증: 알림이 가고, 새로 만든 컨트롤러도 차콜을 읽는다.
    expect(notificationCount, 1);
    expect(
      AppSettingsController(repository).settings.backgroundPreset,
      BackgroundPreset.charcoal,
    );
  });

  test('enableCalendarSync_thenDisable_keepsLastCalendar', () async {
    // 준비: 컨트롤러
    final controller = AppSettingsController(await createRepository());

    // 실행: 켰다가 끈다.
    controller.enableCalendarSync(_calendar);
    controller.disableCalendarSync();

    // 검증: 꺼졌지만 마지막 캘린더는 기억한다.
    expect(controller.settings.isCalendarSyncEnabled, isFalse);
    expect(controller.settings.calendarTarget?.id, _calendar.id);
  });

  test('settings_nothingStored_defaultsToBlackWithCalendarOff', () async {
    // 준비 및 실행: 빈 저장소로 만든다.
    final controller = AppSettingsController(await createRepository());

    // 검증: 기본은 검정 테마, 캘린더 기록 꺼짐
    expect(controller.settings.backgroundPreset, BackgroundPreset.black);
    expect(controller.settings.isCalendarSyncEnabled, isFalse);
  });
}
