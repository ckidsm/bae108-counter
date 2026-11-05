/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the selectable sounds played when the alert mode is bell.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 알림 방식이 종소리일 때 울리는 소리.
enum BellSound {
  // 낮고 길게 울리는 종(기본)
  /// A low, long temple bell (default).
  deep,

  // 높고 맑은 종
  /// A higher, clearer bell.
  clear,

  // 높고 가벼운 풍경
  /// A light, high wind-chime tone.
  chime,

  // 짧은 목탁
  /// A short wooden moktak knock.
  moktak,
}
