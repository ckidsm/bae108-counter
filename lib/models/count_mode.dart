/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines how the counter advances the bow count.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 절 수를 늘리는 방식.
enum CountMode {
  // 사용자가 원을 탭할 때마다 1배씩 센다.
  /// Counts one bow each time the circle is tapped.
  tap,

  // 정해진 간격이 지날 때마다 1배씩 센다.
  /// Counts one bow every configured interval.
  auto,
}
