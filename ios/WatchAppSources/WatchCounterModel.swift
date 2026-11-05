import Foundation

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Counts 108 bows on the watch at the interval set on the iPhone.
 Remarks  : Same rules as lib/controllers/counter_controller.dart: bow 1 starts
            when the 10-second countdown ends, each following bow one interval
            later, and completion one interval after bow 108 started.
            Time only advances through tick(elapsed:), so the logic can be
            exercised without real time.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@MainActor
final class WatchCounterModel: ObservableObject {
  /// The phases of a practice.
  enum Phase {
    // 시작 전
    case idle
    // 준비 카운트다운
    case preparing
    // 절하는 중
    case running
    // 정지(센 수 유지)
    case stopped
    // 108배 완료
    case completed
  }

  /// The number of bows that completes a practice.
  static let targetBowCount = 108
  /// The countdown before bow 1, in seconds.
  static let preparationSeconds: TimeInterval = 10
  // 타이머가 상태를 갱신하는 주기(초)
  private static let tickSeconds: TimeInterval = 0.2

  /// The current phase.
  @Published private(set) var phase: Phase = .idle
  /// The bow currently being performed (1...108), or 0 before bow 1.
  @Published private(set) var count = 0
  /// The whole seconds left in the countdown or until the next signal.
  @Published private(set) var remainingSeconds = 0
  /// The interval between bows, in seconds (received from the iPhone).
  @Published private(set) var intervalSeconds: Int

  // 준비 카운트다운에서 흐른 시간
  private var preparationElapsed: TimeInterval = 0
  // 지금 절을 시작한 뒤 흐른 시간
  private var intervalElapsed: TimeInterval = 0
  // 정지·준비 시간을 뺀 실제 수행 시간
  private var activeElapsed: TimeInterval = 0
  // 첫 절을 시작한 시각
  private var startedAt: Date?
  // 마지막으로 시간을 잰 시각
  private var lastTickAt: Date?
  // 주기 타이머
  private var timer: Timer?

  // 손목 진동
  private let haptics: HapticPlaying
  // 화면이 꺼져도 앱이 계속 돌도록 하는 운동 세션
  private let workout: WorkoutControlling
  // 완료 기록을 iPhone으로 보내는 함수
  private let sendCompleted: ([String: Any]) -> Void

  /// Creates the model.
  init(
    intervalSeconds: Int,
    haptics: HapticPlaying,
    workout: WorkoutControlling,
    sendCompleted: @escaping ([String: Any]) -> Void
  ) {
    // 간격
    self.intervalSeconds = intervalSeconds
    // 진동
    self.haptics = haptics
    // 운동 세션
    self.workout = workout
    // 기록 전송
    self.sendCompleted = sendCompleted
    // 대기 화면에 보일 준비 초
    self.remainingSeconds = Int(Self.preparationSeconds)
  }

  /// Whether the counter is advancing.
  var isActive: Bool { phase == .preparing || phase == .running }

  /// Applies an interval received from the iPhone while not counting.
  func applyInterval(_ seconds: Int) {
    // 진행 중에는 박자가 바뀌지 않도록 무시한다.
    guard !isActive, seconds > 0 else { return }
    // 간격을 바꾼다.
    intervalSeconds = seconds
  }

  /// Starts a practice, or continues after stop without a countdown.
  func start() {
    // 진행 중이거나 끝났으면 무시한다.
    guard !isActive, phase != .completed else { return }
    // 처음 시작이면 운동 세션을 연다.
    if phase == .idle { workout.begin() }
    // 0배면 준비 카운트다운부터, 아니면 바로 이어서 센다.
    phase = count == 0 ? .preparing : .running
    // 준비 시간을 처음부터 잰다.
    if phase == .preparing { preparationElapsed = 0 }
    // 타이머를 시작한다.
    startTimer()
    // 남은 초를 갱신한다.
    updateRemaining()
  }

  /// Stops counting and keeps the count.
  func stop() {
    // 진행 중일 때만 멈춘다.
    guard isActive else { return }
    // 정지 단계
    phase = .stopped
    // 타이머를 멈춘다.
    stopTimer()
  }

  /// Clears the practice and ends the workout session.
  func reset() {
    // 타이머를 멈춘다.
    stopTimer()
    // 운동 세션을 저장하지 않고 닫는다.
    workout.discard()
    // 값을 모두 지운다.
    phase = .idle
    count = 0
    preparationElapsed = 0
    intervalElapsed = 0
    activeElapsed = 0
    startedAt = nil
    // 대기 화면의 준비 초
    remainingSeconds = Int(Self.preparationSeconds)
  }

  /// Advances the practice by [elapsed] seconds.
  func tick(elapsed: TimeInterval) {
    // 단계별로 시간을 진행한다.
    switch phase {
    // 준비 중
    case .preparing:
      // 준비 시간을 진행한다.
      advancePreparation(elapsed)
    // 절하는 중
    case .running:
      // 간격을 진행한다.
      advanceRunning(elapsed)
    // 그 외에는 시간이 흐르지 않는다.
    default:
      return
    }
    // 남은 초를 갱신한다.
    updateRemaining()
  }

  // 준비 카운트다운을 진행하고, 끝나면 진동과 함께 1배를 시작한다.
  private func advancePreparation(_ elapsed: TimeInterval) {
    // 준비 시간에 더한다.
    preparationElapsed += elapsed
    // 아직 남았으면 끝낸다.
    guard preparationElapsed >= Self.preparationSeconds else { return }
    // 넘친 시간
    let overflow = preparationElapsed - Self.preparationSeconds
    // 절하는 단계로 들어간다.
    phase = .running
    // 첫 절 시작 시각
    startedAt = startedAt ?? Date()
    // 진동과 함께 1배를 시작한다.
    startNextBow()
    // 넘친 시간을 반영한다.
    advanceRunning(overflow)
  }

  // 간격이 지날 때마다 다음 절을 시작하고, 108배째 간격이 끝나면 완료한다.
  private func advanceRunning(_ elapsed: TimeInterval) {
    // 실제 수행 시간
    activeElapsed += elapsed
    // 지금 절의 경과 시간
    intervalElapsed += elapsed
    // 간격 길이(초)
    let interval = TimeInterval(intervalSeconds)
    // 지연이 길었어도 놓친 절을 차례로 처리한다.
    while phase == .running && intervalElapsed >= interval {
      // 지난 간격만큼 뺀다.
      intervalElapsed -= interval
      // 108배째 간격까지 끝났으면 완료, 아니면 다음 절
      if count >= Self.targetBowCount {
        // 완료
        finish()
      } else {
        // 다음 절
        startNextBow()
      }
    }
  }

  // 진동 두 번과 함께 다음 절을 시작한다.
  private func startNextBow() {
    // 절 번호를 올린다.
    count += 1
    // 절 시작 진동(톡톡)
    haptics.playBowStart()
  }

  // 완료 진동 두 번, 운동 세션 저장, iPhone으로 기록 전송
  private func finish() {
    // 완료 단계
    phase = .completed
    // 타이머를 멈춘다.
    stopTimer()
    // 완료 진동(강하게 두 번)
    haptics.playCompletion()
    // 운동 세션을 건강 앱에 저장하고 닫는다.
    workout.finish()
    // 종료 시각
    let endedAt = Date()
    // iPhone 앱의 BowSession JSON과 같은 키로 보낸다.
    let formatter = ISO8601DateFormatter()
    // 기록을 보낸다.
    sendCompleted([
      // 종료 시각 마이크로초를 식별자로 쓴다(iPhone 기록과 같은 규칙).
      "id": String(Int64(endedAt.timeIntervalSince1970 * 1_000_000)),
      // 시작 시각(UTC)
      "startedAt": formatter.string(from: startedAt ?? endedAt),
      // 종료 시각(UTC)
      "endedAt": formatter.string(from: endedAt),
      // 실제 수행 시간(초)
      "activeDurationSeconds": Int(activeElapsed),
      // 절 수
      "bowCount": Self.targetBowCount,
      // 워치에서는 메모를 쓰지 않는다.
      "memo": "",
    ])
  }

  // 화면에 보일 남은 초를 계산한다(0.1초라도 남으면 1초로 올림).
  private func updateRemaining() {
    // 단계별 남은 시간
    let remaining: TimeInterval
    // 준비 중이면 준비 시간, 아니면 간격 기준
    switch phase {
    // 준비 중
    case .preparing: remaining = Self.preparationSeconds - preparationElapsed
    // 절하는 중·정지
    case .running, .stopped: remaining = TimeInterval(intervalSeconds) - intervalElapsed
    // 그 외
    default: return
    }
    // 올림한 정수 초
    remainingSeconds = max(1, Int(remaining.rounded(.up)))
  }

  // 주기 타이머를 시작한다(실제 흐른 시간으로 진행해 지연에 강하다).
  private func startTimer() {
    // 이미 돌고 있으면 끝낸다.
    guard timer == nil else { return }
    // 기준 시각
    lastTickAt = Date()
    // 일정 주기로 실제 경과 시간만큼 진행한다.
    timer = Timer.scheduledTimer(withTimeInterval: Self.tickSeconds, repeats: true) { [weak self] _ in
      // 메인 액터에서 처리한다.
      Task { @MainActor in
        // 객체가 살아 있을 때만
        guard let self else { return }
        // 현재 시각
        let now = Date()
        // 흐른 시간(시계가 뒤로 가면 0)
        let elapsed = max(0, now.timeIntervalSince(self.lastTickAt ?? now))
        // 다음 기준
        self.lastTickAt = now
        // 진행
        self.tick(elapsed: elapsed)
      }
    }
  }

  // 타이머를 멈춘다.
  private func stopTimer() {
    // 취소
    timer?.invalidate()
    // 참조 해제
    timer = nil
    // 기준 시각 해제
    lastTickAt = nil
  }
}
