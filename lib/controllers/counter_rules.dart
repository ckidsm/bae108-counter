import '../models/alert_mode.dart';
import '../models/count_mode.dart';
import '../models/counter_settings.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the fixed rules of the 108-bow practice counter.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 108배 카운터의 고정 규칙 값.
abstract final class CounterRules {
  // 목표 절 수
  /// The number of bows that completes a session.
  static const int targetBowCount = 108;

  // 자동 모드 시작 전 준비 카운트다운 길이(초)
  /// The preparation countdown before automatic counting, in seconds.
  static const int preparationSeconds = 10;

  // 진행 구간 바 개수
  /// The number of progress segments shown below the counter.
  static const int segmentCount = 4;

  // 구간 하나에 들어가는 절 수 (108 / 4)
  /// The number of bows in one progress segment.
  static const int bowsPerSegment = targetBowCount ~/ segmentCount;

  // 자동 간격 최솟값(초)
  /// The shortest automatic interval, in seconds.
  static const int minimumIntervalSeconds = 5;

  // 자동 간격 최댓값(초, 3분)
  /// The longest automatic interval, in seconds.
  static const int maximumIntervalSeconds = 180;

  // 직접 설정 슬라이더 이동 단위(초)
  /// The step of the custom interval slider, in seconds.
  static const int intervalStepSeconds = 5;

  // 칩으로 제공하는 간격 프리셋(초)
  /// The interval presets offered as chips, in seconds.
  static const List<int> presetIntervalSeconds = <int>[5, 10, 20];

  // 처음 설치했을 때의 기본 간격(초)
  /// The interval used before the user changes it, in seconds.
  static const int defaultIntervalSeconds = 10;

  // 타이머가 상태를 갱신하는 주기 (안쪽 링을 부드럽게 그리기 위한 값)
  /// How often the running timer advances the controller.
  static const Duration tickInterval = Duration(milliseconds: 100);

  // 처음 설치했을 때의 기본 설정
  /// The settings used before the user changes anything.
  static const CounterSettings defaultSettings = CounterSettings(
    // 기본은 직접 탭 방식
    countMode: CountMode.tap,
    // 기본 간격 10초
    intervalSeconds: defaultIntervalSeconds,
    // 기본 알림은 종소리
    alertMode: AlertMode.bell,
  );

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Clamps an interval to the allowed range and snaps it to the slider step.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Clamps [seconds] to the allowed range and rounds it to [intervalStepSeconds].
  static int normalizeIntervalSeconds(int seconds) {
    // 가장 가까운 5초 단위로 반올림한다.
    final snappedSeconds =
        (seconds / intervalStepSeconds).round() * intervalStepSeconds;
    // 허용 범위(5초~180초) 안으로 제한한다.
    return snappedSeconds.clamp(minimumIntervalSeconds, maximumIntervalSeconds);
  }
}
