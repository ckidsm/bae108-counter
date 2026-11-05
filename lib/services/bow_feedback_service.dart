import '../models/alert_mode.dart';
import '../models/bell_sound.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts the bell, vibration, or silent feedback for each counted bow.
 Remarks  : Lets tests replace device sound and vibration with a fake.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 1배를 셀 때마다 알림을 내보내는 서비스 계약.
abstract interface class BowFeedbackService {
  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Plays the feedback for one counted bow.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Plays the feedback selected by [alertMode], using [bellSound] for bells.
  ///
  /// When [isFinalBow] is true the feedback is longer to mark completion.
  Future<void> notifyBow(
    AlertMode alertMode, {
    required BellSound bellSound,
    required bool isFinalBow,
  });

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Plays one bell sound so the user can hear it before choosing.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Plays [bellSound] once as a preview.
  Future<void> previewBell(BellSound bellSound);

  /// Releases audio resources held by the service.
  Future<void> dispose();
}
