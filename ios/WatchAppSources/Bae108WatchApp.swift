import SwiftUI

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Starts the Apple Watch app and connects the counter, workout, and iPhone link.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@main
struct Bae108WatchApp: App {
  // iPhone 연결
  private let phone: PhoneConnector
  // 운동 세션
  private let workout: WorkoutSessionManager
  // 카운터 상태(화면이 관찰한다)
  @StateObject private var model: WatchCounterModel

  init() {
    // iPhone 연결을 만든다.
    let phone = PhoneConnector()
    // 운동 세션 관리자를 만든다.
    let workout = WorkoutSessionManager()
    // 마지막으로 받은 간격으로 카운터를 만든다.
    let model = WatchCounterModel(
      intervalSeconds: phone.storedIntervalSeconds,
      haptics: WatchHaptics(),
      workout: workout,
      sendCompleted: { phone.sendCompleted($0) }
    )
    // iPhone에서 간격이 바뀌면 반영한다.
    phone.onIntervalReceived = { seconds in
      // 메인 액터에서 반영
      Task { @MainActor in model.applyInterval(seconds) }
    }
    // 연결을 연다.
    phone.activate()
    // 운동 기록 권한을 요청한다(처음 한 번 묻는다).
    workout.requestAuthorization()
    // 보관
    self.phone = phone
    self.workout = workout
    _model = StateObject(wrappedValue: model)
  }

  var body: some Scene {
    // 한 화면 앱
    WindowGroup {
      // 카운터 화면
      ContentView(model: model)
    }
  }
}
