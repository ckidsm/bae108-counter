import SwiftUI

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the bow count, the time to the next signal, and start/stop/restart.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
struct ContentView: View {
  // 카운터 상태
  @ObservedObject var model: WatchCounterModel
  // 처음부터 확인 창 표시 여부
  @State private var isResetConfirmationShown = false

  // 금빛(iPhone 기본 버튼색과 같음)
  private static let gold = Color(red: 0xD9 / 255, green: 0xA4 / 255, blue: 0x41 / 255)
  // 진행 링 주황
  private static let progressOrange = Color(red: 0xF0 / 255, green: 0x8A / 255, blue: 0x3C / 255)
  // 완료 녹색
  private static let completedGreen = Color(red: 0x5F / 255, green: 0xB8 / 255, blue: 0x78 / 255)
  // 정지 빨간색
  private static let stopRed = Color(red: 0xC0 / 255, green: 0x47 / 255, blue: 0x3B / 255)
  // 진행 링 두께
  private static let ringWidth: CGFloat = 8

  var body: some View {
    // 세로 배치
    VStack(spacing: 6) {
      // 원형 진행 링과 숫자
      ring
      // 안내 문구
      Text(guide)
        .font(.footnote)
        .foregroundStyle(model.phase == .completed ? Self.completedGreen : Self.gold)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      // 버튼 줄
      controls
    }
    // 처음부터 확인 창
    .confirmationDialog(
      String(localized: "watch.resetConfirm"),
      isPresented: $isResetConfirmationShown
    ) {
      // 확인하면 처음부터
      Button(String(localized: "watch.reset"), role: .destructive) { model.reset() }
    }
  }

  // 원형 진행 링(바깥: 108배 진행, 가운데: 현재 절 또는 준비 초)
  private var ring: some View {
    // 겹쳐 그린다.
    ZStack {
      // 바탕 링
      Circle().stroke(Color.white.opacity(0.15), lineWidth: Self.ringWidth)
      // 진행 링(완료면 전체 녹색)
      Circle()
        .trim(from: 0, to: model.phase == .completed ? 1 : Double(model.count) / Double(WatchCounterModel.targetBowCount))
        .stroke(
          model.phase == .completed ? Self.completedGreen : Self.progressOrange,
          style: StrokeStyle(lineWidth: Self.ringWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
      // 가운데 숫자
      VStack(spacing: 0) {
        // 준비 중이면 남은 초, 아니면 현재 절
        Text(model.phase == .preparing ? "\(model.remainingSeconds)" : "\(model.count)")
          .font(.system(size: 40, weight: .semibold, design: .rounded))
          .monospacedDigit()
        // "준비" 또는 "/ 108"
        Text(model.phase == .preparing ? String(localized: "watch.prepare") : "/ \(WatchCounterModel.targetBowCount)")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    // 화면에 맞는 크기
    .frame(maxWidth: 110, maxHeight: 110)
  }

  // 단계별 안내 문구
  private var guide: String {
    // 단계별로 고른다.
    switch model.phase {
    // 대기: 간격 표시
    case .idle: return String(localized: "watch.interval \(model.intervalSeconds)")
    // 준비
    case .preparing: return String(localized: "watch.prepareGuide")
    // 108배째 절이면 완료까지, 아니면 다음 절까지
    case .running:
      return model.count >= WatchCounterModel.targetBowCount
        ? String(localized: "watch.finalBow \(model.remainingSeconds)")
        : String(localized: "watch.nextBow \(model.remainingSeconds)")
    // 정지
    case .stopped: return String(localized: "watch.stopped")
    // 완료
    case .completed: return String(localized: "watch.completed")
    }
  }

  // 시작 | 정지 | 처음부터
  private var controls: some View {
    // 가로 배치
    HStack(spacing: 6) {
      // 시작(진행 중·완료 후에는 비활성)
      Button { model.start() } label: { Image(systemName: "play.fill") }
        .tint(Self.gold)
        .disabled(model.isActive || model.phase == .completed)
        .accessibilityLabel(String(localized: "watch.start"))
      // 정지(진행 중에만 활성)
      Button { model.stop() } label: { Image(systemName: "stop.fill") }
        .tint(Self.stopRed)
        .disabled(!model.isActive)
        .accessibilityLabel(String(localized: "watch.stop"))
      // 처음부터(확인 후, 시작 전에는 비활성)
      Button { isResetConfirmationShown = true } label: { Image(systemName: "arrow.counterclockwise") }
        .disabled(model.phase == .idle)
        .accessibilityLabel(String(localized: "watch.reset"))
    }
    // 눌리는 모양
    .buttonStyle(.borderedProminent)
  }
}
