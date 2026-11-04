import 'accent_preset.dart';
import 'background_preset.dart';
import 'calendar_target.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds app-wide preferences such as the theme and calendar sync.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 테마와 캘린더 기록 같은 앱 전체 설정.
class AppSettings {
  /// Creates app settings.
  const AppSettings({
    this.backgroundPreset = BackgroundPreset.black,
    this.accentPreset = AccentPreset.gold,
    this.isCalendarSyncEnabled = false,
    this.calendarTarget,
  });

  // JSON 키: 배경색
  static const String _backgroundPresetKey = 'backgroundPreset';
  // JSON 키: 버튼색
  static const String _accentPresetKey = 'accentPreset';
  // JSON 키: 캘린더 기록 사용 여부
  static const String _isCalendarSyncEnabledKey = 'isCalendarSyncEnabled';
  // JSON 키: 기록할 캘린더
  static const String _calendarTargetKey = 'calendarTarget';

  /// The selected background color.
  final BackgroundPreset backgroundPreset;

  /// The selected button/accent color.
  final AccentPreset accentPreset;

  /// Whether saved records are also added to [calendarTarget].
  final bool isCalendarSyncEnabled;

  /// The calendar that receives practice events, if one was chosen.
  final CalendarTarget? calendarTarget;

  /// Whether a saved record should be written to the calendar.
  bool get shouldWriteToCalendar =>
      isCalendarSyncEnabled && calendarTarget != null;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns a copy with the given values replaced.
   Remarks  : Pass clearCalendarTarget to remove the selected calendar.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns a copy with the given values replaced.
  AppSettings copyWith({
    BackgroundPreset? backgroundPreset,
    AccentPreset? accentPreset,
    bool? isCalendarSyncEnabled,
    CalendarTarget? calendarTarget,
    bool clearCalendarTarget = false,
  }) {
    // 넘겨받은 값만 바꾸고 나머지는 유지한다.
    return AppSettings(
      // 배경색
      backgroundPreset: backgroundPreset ?? this.backgroundPreset,
      // 버튼색
      accentPreset: accentPreset ?? this.accentPreset,
      // 캘린더 기록 사용 여부
      isCalendarSyncEnabled:
          isCalendarSyncEnabled ?? this.isCalendarSyncEnabled,
      // 캘린더를 지우라고 했으면 null, 아니면 새 값 또는 기존 값
      calendarTarget: clearCalendarTarget
          ? null
          : calendarTarget ?? this.calendarTarget,
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Restores settings from JSON, using defaults for invalid values.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Restores settings from [json], using defaults for missing or invalid values.
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // 저장된 배경색 이름을 열거형으로 바꾸고, 없으면 검정을 쓴다.
    final backgroundPreset =
        BackgroundPreset.values.asNameMap()[json[_backgroundPresetKey]] ??
        BackgroundPreset.black;
    // 저장된 버튼색 이름을 열거형으로 바꾸고, 없으면 금빛을 쓴다.
    final accentPreset =
        AccentPreset.values.asNameMap()[json[_accentPresetKey]] ??
        AccentPreset.gold;
    // 캘린더 기록 사용 여부(불리언이 아니면 꺼짐)
    final isCalendarSyncEnabled = json[_isCalendarSyncEnabledKey] == true;
    // 복원한 설정
    return AppSettings(
      // 배경색
      backgroundPreset: backgroundPreset,
      // 버튼색
      accentPreset: accentPreset,
      // 캘린더 기록 사용 여부
      isCalendarSyncEnabled: isCalendarSyncEnabled,
      // 기록할 캘린더
      calendarTarget: CalendarTarget.tryFromJson(json[_calendarTargetKey]),
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Converts the settings to a JSON-compatible map.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Converts the settings to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    // 세 값을 저장한다.
    return <String, dynamic>{
      // 배경색 이름
      _backgroundPresetKey: backgroundPreset.name,
      // 버튼색 이름
      _accentPresetKey: accentPreset.name,
      // 캘린더 기록 사용 여부
      _isCalendarSyncEnabledKey: isCalendarSyncEnabled,
      // 기록할 캘린더(없으면 null)
      _calendarTargetKey: calendarTarget?.toJson(),
    };
  }
}
