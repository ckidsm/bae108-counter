import WatchKit

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts the wrist taps so the counter logic does not depend on WatchKit.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@MainActor
protocol HapticPlaying {
  /// Taps twice to signal the start of a bow.
  func playBowStart()
  /// Vibrates strongly twice to signal completion.
  func playCompletion()
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Plays the bow-start and completion patterns on the Apple Watch.
 Remarks  : Haptics keep playing with the screen off while a workout session runs.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@MainActor
final class WatchHaptics: HapticPlaying {
  // 절 시작 두 번 사이 간격(초)
  private static let bowStartGap: TimeInterval = 0.35
  // 완료 두 번 사이 간격(초)
  private static let completionGap: TimeInterval = 0.9

  func playBowStart() {
    // 짧고 또렷한 진동을 두 번(톡톡)
    playTwice(.start, gap: Self.bowStartGap)
  }

  func playCompletion() {
    // 강한 알림 진동을 두 번
    playTwice(.notification, gap: Self.completionGap)
  }

  // 같은 진동을 간격을 두고 두 번 울린다.
  private func playTwice(_ type: WKHapticType, gap: TimeInterval) {
    // 첫 번째
    WKInterfaceDevice.current().play(type)
    // 두 번째
    DispatchQueue.main.asyncAfter(deadline: .now() + gap) {
      // 같은 진동
      WKInterfaceDevice.current().play(type)
    }
  }
}
