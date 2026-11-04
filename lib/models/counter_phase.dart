/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the lifecycle phases of a 108-bow practice session.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 진행 단계.
enum CounterPhase {
  // 아직 시작하지 않은 상태.
  /// The session has not started yet.
  idle,

  // 자동 모드의 시작 전 준비 카운트다운 중인 상태.
  /// The preparation countdown before automatic counting is running.
  preparing,

  // 절을 세는 중인 상태.
  /// Bows are being counted.
  running,

  // 사용자가 잠시 멈춘 상태.
  /// The session is paused by the user.
  paused,

  // 목표 절 수에 도달해 끝난 상태.
  /// The target bow count has been reached.
  completed,
}
