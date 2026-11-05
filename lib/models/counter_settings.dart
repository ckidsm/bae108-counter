import 'alert_mode.dart';
import 'bell_sound.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds the user-selected counter options that persist between launches.
 Remarks  : Older stored data may still contain a countMode key; it is ignored.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 앱을 다시 열어도 유지되는 카운터 설정.
class CounterSettings {
  /// Creates settings with the given options.
  const CounterSettings({
    required this.intervalSeconds,
    required this.alertMode,
    this.bellSound = BellSound.deep,
  });

  // JSON 키: 절 간격(초)
  static const String _intervalSecondsKey = 'intervalSeconds';
  // JSON 키: 알림 방식
  static const String _alertModeKey = 'alertMode';
  // JSON 키: 종소리 종류
  static const String _bellSoundKey = 'bellSound';

  /// The automatic interval between bows, in seconds.
  final int intervalSeconds;

  /// The feedback played for each bow.
  final AlertMode alertMode;

  /// The sound played when [alertMode] is bell.
  final BellSound bellSound;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Restores settings from JSON, falling back to defaults for unknown values.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Restores settings from [json], using [fallback] for missing or invalid values.
  factory CounterSettings.fromJson(
    Map<String, dynamic> json,
    CounterSettings fallback,
  ) {
    // 저장된 알림 방식 이름을 열거형으로 바꾸고, 없으면 기본값을 쓴다.
    final alertMode =
        AlertMode.values.asNameMap()[json[_alertModeKey]] ?? fallback.alertMode;
    // 저장된 종소리 이름을 열거형으로 바꾸고, 없으면 기본값을 쓴다.
    final bellSound =
        BellSound.values.asNameMap()[json[_bellSoundKey]] ?? fallback.bellSound;
    // 저장된 간격 값
    final intervalValue = json[_intervalSecondsKey];
    // 정수일 때만 저장된 간격을 사용한다.
    final intervalSeconds = intervalValue is int
        ? intervalValue
        : fallback.intervalSeconds;
    // 복원한 값으로 설정 객체를 만든다.
    return CounterSettings(
      intervalSeconds: intervalSeconds,
      alertMode: alertMode,
      bellSound: bellSound,
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
      // 절 간격(초)
      _intervalSecondsKey: intervalSeconds,
      // 알림 방식 이름
      _alertModeKey: alertMode.name,
      // 종소리 이름
      _bellSoundKey: bellSound.name,
    };
  }
}
