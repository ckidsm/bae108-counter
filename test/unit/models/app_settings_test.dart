import 'package:bae108_counter/models/accent_preset.dart';
import 'package:bae108_counter/models/app_settings.dart';
import 'package:bae108_counter/models/background_preset.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson_thenFromJson_restoresThemeAndCalendar', () {
    // 준비: 네이비 테마, 캘린더 기록 켬
    const original = AppSettings(
      backgroundPreset: BackgroundPreset.navy,
      accentPreset: AccentPreset.deepBlue,
      isCalendarSyncEnabled: true,
      calendarTarget: CalendarTarget(
        id: 'calendar-1',
        name: '내 캘린더',
        accountName: 'tester@gmail.com',
      ),
    );

    // 실행: JSON으로 바꿨다가 되돌린다.
    final restored = AppSettings.fromJson(original.toJson());

    // 검증: 같은 값이 복원된다.
    expect(restored.backgroundPreset, BackgroundPreset.navy);
    expect(restored.accentPreset, AccentPreset.deepBlue);
    expect(restored.isCalendarSyncEnabled, isTrue);
    expect(restored.calendarTarget?.id, 'calendar-1');
    expect(restored.calendarTarget?.accountName, 'tester@gmail.com');
  });

  test('fromJson_unknownValues_usesDefaults', () {
    // 준비: 알 수 없는 값
    final json = <String, dynamic>{
      'backgroundPreset': 'rainbow',
      'accentPreset': 'neon',
      'isCalendarSyncEnabled': 'yes',
      'calendarTarget': 42,
    };

    // 실행: 복원한다.
    final restored = AppSettings.fromJson(json);

    // 검증: 기본값으로 대체된다.
    expect(restored.backgroundPreset, BackgroundPreset.black);
    expect(restored.accentPreset, AccentPreset.gold);
    expect(restored.isCalendarSyncEnabled, isFalse);
    expect(restored.calendarTarget, isNull);
  });

  test('shouldWriteToCalendar_enabledWithoutCalendar_returnsFalse', () {
    // 준비 및 실행: 켜졌지만 캘린더가 없는 설정
    const settings = AppSettings(isCalendarSyncEnabled: true);

    // 검증: 기록하지 않는다.
    expect(settings.shouldWriteToCalendar, isFalse);
  });

  test('copyWith_clearCalendarTarget_removesCalendar', () {
    // 준비: 캘린더가 있는 설정
    const settings = AppSettings(
      calendarTarget: CalendarTarget(id: 'c', name: 'n', accountName: ''),
    );

    // 실행: 캘린더를 지운다.
    final cleared = settings.copyWith(clearCalendarTarget: true);

    // 검증: 캘린더가 사라진다.
    expect(cleared.calendarTarget, isNull);
  });
}
