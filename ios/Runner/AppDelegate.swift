import Flutter
import UIKit
import WatchConnectivity

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Starts the Flutter app and registers the Apple Watch bridge.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
 History  : [2026-11-05, YUNDEOKSOO] Registered WatchSyncPlugin for Apple Watch sync
────────────────────────────────────────────────────────────────────────*/
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 워치 기록은 Flutter 엔진보다 먼저 도착할 수 있으므로 연결을 가장 먼저 연다.
    WatchSyncPlugin.shared.activate()
    // Flutter 기본 시작 처리
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // pubspec 플러그인을 등록한다.
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // 워치 연동 채널을 등록한다.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: WatchSyncPlugin.pluginName) {
      // 채널 연결
      WatchSyncPlugin.register(with: registrar)
    }
  }
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Bridges Flutter and the Apple Watch app through WatchConnectivity.
 Remarks  : Watch records are queued in UserDefaults until Flutter takes them,
            so records delivered while Flutter is not running are not lost.
            Channel names must match lib/services/method_channel_watch_sync_service.dart.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
final class WatchSyncPlugin: NSObject, FlutterPlugin, WCSessionDelegate {
  /// The registrar key of this plugin.
  static let pluginName = "WatchSyncPlugin"
  /// The single instance shared by the app delegate and the channel.
  static let shared = WatchSyncPlugin()

  // 채널 이름(Dart의 WatchChannelContract.channelName과 같아야 한다)
  private static let channelName = "com.ckidsm.bae108/watch"
  // Flutter → iOS: 설정 보내기
  private static let sendSettingsMethod = "sendSettings"
  // Flutter → iOS: 쌓인 기록 가져오기
  private static let takePendingSessionsMethod = "takePendingSessions"
  // iOS → Flutter: 새 기록 도착 알림
  private static let sessionsAvailableMethod = "sessionsAvailable"
  // 워치에서 온 기록을 쌓아 두는 UserDefaults 키
  private static let pendingSessionsKey = "watch_pending_sessions_v1"

  // Flutter와 통신하는 채널(엔진이 준비되면 생긴다)
  private var channel: FlutterMethodChannel?
  // 쌓인 기록을 읽고 쓰는 저장소
  private let defaults = UserDefaults.standard

  /// Registers the method channel with the Flutter engine.
  static func register(with registrar: FlutterPluginRegistrar) {
    // 채널을 만든다.
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    // 공유 인스턴스가 채널을 쓴다.
    shared.channel = channel
    // Flutter 호출을 공유 인스턴스가 처리한다.
    registrar.addMethodCallDelegate(shared, channel: channel)
  }

  /// Activates the WatchConnectivity session if the device supports it.
  func activate() {
    // 워치를 지원하지 않는 기기(iPad 등)면 끝낸다.
    guard WCSession.isSupported() else { return }
    // 이 객체가 연결 이벤트를 받는다.
    WCSession.default.delegate = self
    // 연결을 연다.
    WCSession.default.activate()
  }

  /// Handles calls from Flutter.
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // 메서드별로 처리한다.
    switch call.method {
    // 설정 보내기
    case WatchSyncPlugin.sendSettingsMethod:
      // 설정을 보내고 결과를 돌려준다.
      sendSettings(call.arguments as? [String: Any] ?? [:])
      // 완료
      result(nil)
    // 쌓인 기록 가져오기
    case WatchSyncPlugin.takePendingSessionsMethod:
      // 쌓인 기록을 돌려주고 비운다.
      result(takePendingSessions())
    // 모르는 메서드
    default:
      // 구현되지 않음
      result(FlutterMethodNotImplemented)
    }
  }

  // 설정을 워치로 보낸다(워치가 꺼져 있어도 다음 실행 때 받도록 applicationContext 사용).
  private func sendSettings(_ settings: [String: Any]) {
    // 연결이 열려 있고 워치 앱이 설치돼 있을 때만 보낸다.
    guard WCSession.isSupported(),
          WCSession.default.activationState == .activated,
          WCSession.default.isWatchAppInstalled else { return }
    // 보내기는 실패할 수 있다.
    do {
      // 마지막 설정만 유지되는 방식으로 보낸다.
      try WCSession.default.updateApplicationContext(settings)
    } catch {
      // 실패 원인을 남긴다.
      NSLog("[WatchSync] 설정 전송 실패: \(error.localizedDescription)")
    }
  }

  // 쌓인 기록을 꺼내고 비운다.
  private func takePendingSessions() -> [[String: Any]] {
    // 저장된 기록 목록
    let sessions = defaults.array(forKey: WatchSyncPlugin.pendingSessionsKey) as? [[String: Any]] ?? []
    // 가져갔으니 비운다.
    defaults.removeObject(forKey: WatchSyncPlugin.pendingSessionsKey)
    // 돌려준다.
    return sessions
  }

  // 워치가 보낸 기록을 쌓고 Flutter에 알린다.
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    // UI 스레드에서 처리한다(채널 호출은 메인 스레드에서 해야 한다).
    DispatchQueue.main.async {
      // 기존 목록에 더한다.
      var sessions = self.defaults.array(forKey: WatchSyncPlugin.pendingSessionsKey) as? [[String: Any]] ?? []
      // 새 기록 추가
      sessions.append(userInfo)
      // 저장한다.
      self.defaults.set(sessions, forKey: WatchSyncPlugin.pendingSessionsKey)
      // Flutter가 실행 중이면 가져가라고 알린다.
      self.channel?.invokeMethod(WatchSyncPlugin.sessionsAvailableMethod, arguments: nil)
    }
  }

  // 연결이 열렸을 때(실패 원인만 남긴다).
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    // 오류가 있으면 남긴다.
    if let error {
      // 실패 원인
      NSLog("[WatchSync] 연결 실패: \(error.localizedDescription)")
    }
  }

  // 다른 워치로 바꾸는 중(iOS 필수 구현, 할 일 없음).
  func sessionDidBecomeInactive(_ session: WCSession) {}

  // 워치를 바꾼 뒤 새 워치와 다시 연결한다.
  func sessionDidDeactivate(_ session: WCSession) {
    // 새 워치와 연결을 다시 연다.
    WCSession.default.activate()
  }
}
