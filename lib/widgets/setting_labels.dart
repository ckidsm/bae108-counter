import '../l10n/generated/app_localizations.dart';
import '../models/alert_mode.dart';
import '../models/bell_sound.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Maps alert modes and bell sounds to their localized names.
 Remarks  : Shared by the main screen summary bar and the settings screen.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 알림 방식과 종소리의 화면 표시 이름.
abstract final class SettingLabels {
  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the localized name of an alert mode.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the localized name of [alertMode].
  static String alertModeName(
    AppLocalizations localizations,
    AlertMode alertMode,
  ) {
    // 알림 방식별 번역 이름
    return switch (alertMode) {
      // 종소리
      AlertMode.bell => localizations.alertModeBell,
      // 진동
      AlertMode.vibration => localizations.alertModeVibration,
      // 무음
      AlertMode.silent => localizations.alertModeSilent,
    };
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the localized name of a bell sound.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the localized name of [bellSound].
  static String bellSoundName(
    AppLocalizations localizations,
    BellSound bellSound,
  ) {
    // 소리별 번역 이름
    return switch (bellSound) {
      // 중저음 종
      BellSound.deep => localizations.soundDeep,
      // 맑은 종
      BellSound.clear => localizations.soundClear,
      // 풍경
      BellSound.chime => localizations.soundChime,
      // 목탁
      BellSound.moktak => localizations.soundMoktak,
      // 범종
      BellSound.templeBell => localizations.soundTempleBell,
    };
  }
}
