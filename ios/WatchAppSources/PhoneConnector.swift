import Foundation
import WatchConnectivity

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Receives the interval from the iPhone and sends completed practices back.
 Remarks  : Keys must match ios/Runner/AppDelegate.swift and
            lib/services/method_channel_watch_sync_service.dart.
            transferUserInfo queues records until the iPhone receives them.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
final class PhoneConnector: NSObject, WCSessionDelegate {
  /// The key carrying the interval in the iPhone's application context.
  static let intervalSecondsKey = "intervalSeconds"
  // 마지막으로 받은 간격을 저장하는 키
  private static let storedIntervalKey = "watch_interval_seconds"
  // 처음 설치했을 때의 간격(초, iPhone 기본값과 같다)
  private static let defaultIntervalSeconds = 10

  /// Called on the main thread when the iPhone sends a new interval.
  var onIntervalReceived: ((Int) -> Void)?

  /// The last interval received from the iPhone, or the default.
  var storedIntervalSeconds: Int {
    // 저장된 값
    let stored = UserDefaults.standard.integer(forKey: Self.storedIntervalKey)
    // 없으면(0) 기본값
    return stored > 0 ? stored : Self.defaultIntervalSeconds
  }

  /// Opens the connection to the iPhone.
  func activate() {
    // 지원하지 않으면 끝낸다.
    guard WCSession.isSupported() else { return }
    // 이벤트를 받는다.
    WCSession.default.delegate = self
    // 연결을 연다.
    WCSession.default.activate()
  }

  /// Sends a completed practice to the iPhone (queued until delivered).
  func sendCompleted(_ record: [String: Any]) {
    // 연결이 열려 있어야 보낼 수 있다.
    guard WCSession.default.activationState == .activated else { return }
    // 대기열에 넣어 보낸다.
    WCSession.default.transferUserInfo(record)
  }

  // 연결이 열리면 마지막으로 받아 둔 설정을 반영한다.
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    // 오류가 있으면 남긴다.
    if let error { NSLog("[Phone] 연결 실패: \(error.localizedDescription)") }
    // 이미 받아 둔 설정을 반영한다.
    apply(session.receivedApplicationContext)
  }

  // iPhone이 새 설정을 보냈다.
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    // 반영한다.
    apply(applicationContext)
  }

  // 설정에서 간격을 꺼내 저장하고 알린다.
  private func apply(_ context: [String: Any]) {
    // 간격이 없으면 끝낸다.
    guard let seconds = context[Self.intervalSecondsKey] as? Int, seconds > 0 else { return }
    // 다음 실행을 위해 저장한다.
    UserDefaults.standard.set(seconds, forKey: Self.storedIntervalKey)
    // 화면 모델에 알린다(메인 스레드).
    DispatchQueue.main.async { self.onIntervalReceived?(seconds) }
  }
}
