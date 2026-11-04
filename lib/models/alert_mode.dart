/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the feedback played whenever a bow is counted.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 1배마다 알려 주는 방식.
enum AlertMode {
  // 종소리를 재생한다.
  /// Plays the bell sound.
  bell,

  // 기기를 진동시킨다.
  /// Vibrates the device.
  vibration,

  // 아무 알림도 하지 않는다.
  /// Gives no feedback.
  silent,
}
