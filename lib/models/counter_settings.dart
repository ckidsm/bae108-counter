import 'alert_mode.dart';
import 'count_mode.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds the user-selected counter options that persist between launches.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 앱을 다시 열어도 유지되는 카운터 설정.
class CounterSettings {
  /// Creates settings with the given options.
  const CounterSettings({
    required this.countMode,
    required this.intervalSeconds,
    required this.alertMode,
  });

  // JSON 키: 카운트 방식
  static const String _countModeKey = 'countMode';
  // JSON 키: 절 간격(초)
  static const String _intervalSecondsKey = 'intervalSeconds';
  // JSON 키: 알림 방식
  static const String _alertModeKey = 'alertMode';

  /// The way bows are counted.
  final CountMode countMode;

  /// The automatic interval between bows, in seconds.
  final int intervalSeconds;

  /// The feedback played for each bow.
  final AlertMode alertMode;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Restores settings from JSON, falling back to defaults for unknown values.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Restores settings from [json], using [fallback] for missing or invalid values.
  factory CounterSettings.fromJson(
    Map<String, dynamic> json,
    CounterSettings fallback,
  ) {
    // 저장된 카운트 방식 이름을 열거형으로 바꾸고, 없으면 기본값을 쓴다.
    final countMode =
        CountMode.values.asNameMap()[json[_countModeKey]] ?? fallback.countMode;
    // 저장된 알림 방식 이름을 열거형으로 바꾸고, 없으면 기본값을 쓴다.
    final alertMode =
        AlertMode.values.asNameMap()[json[_alertModeKey]] ?? fallback.alertMode;
    // 저장된 간격 값이 정수가 아니면 기본값을 쓴다.
    final intervalValue = json[_intervalSecondsKey];
    // 정수일 때만 저장된 간격을 사용한다.
    final intervalSeconds = intervalValue is int
        ? intervalValue
        : fallback.intervalSeconds;
    // 복원한 값으로 설정 객체를 만든다.
    return CounterSettings(
      countMode: countMode,
      intervalSeconds: intervalSeconds,
      alertMode: alertMode,
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Converts the settings to a JSON-compatible map.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Converts the settings to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    // 열거형은 이름 문자열로 저장해 순서가 바뀌어도 안전하게 한다.
    return <String, dynamic>{
      // 카운트 방식 이름
      _countModeKey: countMode.name,
      // 절 간격(초)
      _intervalSecondsKey: intervalSeconds,
      // 알림 방식 이름
      _alertModeKey: alertMode.name,
    };
  }
}
