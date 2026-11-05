import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/alert_mode.dart';
import '../models/bell_sound.dart';
import '../models/bow_session.dart';
import '../models/counter_phase.dart';
import '../models/counter_settings.dart';
import '../services/bow_feedback_service.dart';
import '../services/wake_lock_service.dart';
import 'counter_rules.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Counts 108 bows automatically at a set interval after a preparation countdown.
 Remarks  : Time only advances through tick(), so tests can disable the internal
            timer and call tick() directly with a chosen elapsed duration.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 시작하면 준비 카운트다운 뒤 설정한 초 간격으로 108배를 자동으로 세는 컨트롤러.
class CounterController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// Set `isTimerEnabled` to false in tests and advance time with [tick].
  CounterController({
    required this._feedbackService,
    required this._wakeLockService,
    CounterSettings settings = CounterRules.defaultSettings,
    DateTime Function()? now,
    this._isTimerEnabled = true,
  }) : _intervalSeconds = CounterRules.normalizeIntervalSeconds(
         settings.intervalSeconds,
       ),
       _alertMode = settings.alertMode,
       _bellSound = settings.bellSound,
       _now = now ?? clock.now;

  // 1배마다 소리·진동을 내는 서비스
  final BowFeedbackService _feedbackService;
  // 화면 켜짐을 유지하는 서비스
  final WakeLockService _wakeLockService;
  // 현재 시각을 돌려주는 함수(기본은 package:clock이라 위젯 테스트의 가짜 시간을 따른다)
  final DateTime Function() _now;
  // 내부 주기 타이머 사용 여부(테스트에서는 끔)
  final bool _isTimerEnabled;

  // 마지막으로 시간을 잰 시각(타이머 지연과 무관하게 실제 경과 시간을 재기 위함)
  DateTime? _lastTickAt;
  // 주기적으로 tick()을 부르는 타이머
  Timer? _tickTimer;

  // 지금까지 센 절 수
  int _count = 0;
  // 자동 간격(초)
  int _intervalSeconds;
  // 알림 방식
  AlertMode _alertMode;
  // 종소리 종류
  BellSound _bellSound;
  // 진행 단계
  CounterPhase _phase = CounterPhase.idle;
  // 준비 카운트다운에서 흐른 시간
  Duration _preparationElapsed = Duration.zero;
  // 마지막 절 이후 흐른 시간(자동 간격용)
  Duration _intervalElapsed = Duration.zero;
  // 정지·준비 시간을 뺀 실제 수행 시간
  Duration _activeElapsed = Duration.zero;
  // 첫 절을 세기 시작한 시각
  DateTime? _startedAt;
  // 108배를 마친 시각
  DateTime? _endedAt;
  // 화면 켜짐 유지가 켜져 있는지 여부
  bool _isWakeLockEnabled = false;

  /// The number of bows counted so far.
  int get count => _count;

  /// The automatic interval between bows, in seconds.
  int get intervalSeconds => _intervalSeconds;

  /// The feedback played for each bow.
  AlertMode get alertMode => _alertMode;

  /// The sound played when [alertMode] is bell.
  BellSound get bellSound => _bellSound;

  /// The current lifecycle phase.
  CounterPhase get phase => _phase;

  /// The practice time excluding pauses and preparation.
  Duration get activeElapsed => _activeElapsed;

  /// The time the first bow started counting, if the practice has started.
  DateTime? get startedAt => _startedAt;

  /// The time the final bow was counted, if the practice has completed.
  DateTime? get endedAt => _endedAt;

  /// Whether time is currently advancing (preparing or counting).
  bool get isActive =>
      _phase == CounterPhase.preparing || _phase == CounterPhase.running;

  /// Whether the target bow count has been reached.
  bool get isCompleted => _phase == CounterPhase.completed;

  /// The overall progress from 0.0 to 1.0.
  double get progress => _count / CounterRules.targetBowCount;

  /// The seconds left in the preparation countdown, from 10 down to 1.
  int get preparationRemainingSeconds {
    // 준비 시간 중 이미 지난 초를 정수로 구한다.
    final elapsedSeconds = _preparationElapsed.inSeconds;
    // 남은 초를 1 이상으로 돌려준다.
    return (CounterRules.preparationSeconds - elapsedSeconds).clamp(
      1,
      CounterRules.preparationSeconds,
    );
  }

  /// The whole seconds left until the next automatic bow, rounded up.
  int get nextBowRemainingSeconds {
    // 간격 전체에서 이미 흐른 시간을 뺀다.
    final remaining = _intervalDuration - _intervalElapsed;
    // 0.1초라도 남았으면 1초로 보이도록 올림한다.
    return (remaining.inMilliseconds / Duration.millisecondsPerSecond).ceil();
  }

  /// The progress of the inner ring from 0.0 to 1.0.
  ///
  /// Shows the preparation countdown while preparing and the time to the next
  /// bow while counting or stopped; otherwise it is empty.
  double get innerRingProgress {
    // 준비 중에는 준비 시간 진행률을 보여 준다.
    if (_phase == CounterPhase.preparing) {
      // 준비 시간 중 흐른 비율
      return _preparationElapsed.inMilliseconds /
          _preparationDuration.inMilliseconds;
    }
    // 절을 세는 중이거나 정지한 상태면 간격 진행률을 보여 준다.
    final isCounting =
        _phase == CounterPhase.running || _phase == CounterPhase.paused;
    // 그 외에는 안쪽 링을 비운다.
    if (!isCounting) {
      // 비어 있는 링
      return 0;
    }
    // 간격 중 흐른 비율
    return _intervalElapsed.inMilliseconds / _intervalDuration.inMilliseconds;
  }

  // 자동 간격을 Duration으로 바꾼 값
  Duration get _intervalDuration => Duration(seconds: _intervalSeconds);

  // 준비 카운트다운 길이
  Duration get _preparationDuration =>
      const Duration(seconds: CounterRules.preparationSeconds);

  /// The current options as a settings object for persistence.
  CounterSettings get settings => CounterSettings(
    // 자동 간격
    intervalSeconds: _intervalSeconds,
    // 알림 방식
    alertMode: _alertMode,
    // 종소리 종류
    bellSound: _bellSound,
  );

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Advances the preparation countdown and automatic interval by elapsed time.
   Remarks  : Called by the internal timer, or directly by tests.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Advances the controller by [elapsed].
  void tick(Duration elapsed) {
    // 준비 중이면 준비 카운트다운을 진행한다.
    if (_phase == CounterPhase.preparing) {
      // 준비 시간을 진행한다(끝나면 남은 시간은 수행 시간으로 넘긴다).
      _advancePreparation(elapsed);
    } else if (_phase == CounterPhase.running) {
      // 절을 세는 중이면 수행 시간과 간격을 진행한다.
      _advanceRunning(elapsed);
    } else {
      // 시간이 흐르지 않는 단계에서는 아무것도 하지 않는다.
      return;
    }
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Starts a new practice or resumes a stopped one.
   Remarks  : The preparation countdown runs only when starting from zero bows.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Starts counting, or resumes after [stop].
  ///
  /// At zero bows a preparation countdown runs first; resuming with bows
  /// already counted skips it.
  void start() {
    // 이미 진행 중이거나 끝났으면 무시한다.
    if (isActive || isCompleted) {
      // 바꿀 상태가 없다.
      return;
    }
    // 0배부터 시작하면 준비 카운트다운을 먼저 한다.
    if (_count == 0) {
      // 준비 단계로 들어간다.
      _phase = CounterPhase.preparing;
      // 준비 시간을 처음부터 잰다.
      _preparationElapsed = Duration.zero;
    } else {
      // 바로 절을 세는 단계로 들어간다.
      _enterRunning();
    }
    // 수행이 끝날 때까지 화면을 켜 둔다.
    _enableWakeLock();
    // 시간 진행용 타이머를 시작한다.
    _startTimer();
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Stops the preparation countdown or counting while keeping the count.
   Remarks  : Keeps the wake lock because the practice is not finished.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Stops counting and keeps the count. The screen stays on until completion or reset.
  void stop() {
    // 진행 중이 아니면 멈출 것이 없다.
    if (!isActive) {
      // 바꿀 상태가 없다.
      return;
    }
    // 정지 단계로 바꾼다.
    _phase = CounterPhase.paused;
    // 타이머를 멈춘다.
    _stopTimer();
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Clears the practice and returns to the idle state.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Clears all progress and lets the screen turn off again.
  void reset() {
    // 타이머를 멈춘다.
    _stopTimer();
    // 절 수를 0으로 돌린다.
    _count = 0;
    // 대기 단계로 돌린다.
    _phase = CounterPhase.idle;
    // 준비 시간을 지운다.
    _preparationElapsed = Duration.zero;
    // 간격 시간을 지운다.
    _intervalElapsed = Duration.zero;
    // 수행 시간을 지운다.
    _activeElapsed = Duration.zero;
    // 시작 시각을 지운다.
    _startedAt = null;
    // 종료 시각을 지운다.
    _endedAt = null;
    // 화면 켜짐 유지를 해제한다.
    _disableWakeLock();
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Changes the automatic interval and restarts the current interval.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Changes the automatic interval, clamped to 5–180 seconds in 5-second steps.
  void setIntervalSeconds(int seconds) {
    // 허용 범위와 단위에 맞게 보정한다.
    final normalizedSeconds = CounterRules.normalizeIntervalSeconds(seconds);
    // 같은 값이면 바꾸지 않는다.
    if (normalizedSeconds == _intervalSeconds) {
      // 바꿀 상태가 없다.
      return;
    }
    // 간격을 바꾼다.
    _intervalSeconds = normalizedSeconds;
    // 바뀐 간격으로 다음 절까지를 처음부터 다시 잰다.
    _intervalElapsed = Duration.zero;
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Changes the per-bow feedback.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Changes the feedback played for each bow.
  void setAlertMode(AlertMode alertMode) {
    // 같은 값이면 바꾸지 않는다.
    if (alertMode == _alertMode) {
      // 바꿀 상태가 없다.
      return;
    }
    // 알림 방식을 바꾼다.
    _alertMode = alertMode;
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Changes the bell sound and plays it once as a preview.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Changes the bell sound to [bellSound] and plays it once.
  void setBellSound(BellSound bellSound) {
    // 고른 소리를 바로 들려준다(같은 소리를 다시 눌러도 들려준다).
    unawaited(_previewBell(bellSound));
    // 같은 값이면 상태는 바꾸지 않는다.
    if (bellSound == _bellSound) {
      // 바꿀 상태가 없다.
      return;
    }
    // 종소리를 바꾼다.
    _bellSound = bellSound;
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Builds the record of a completed practice.
   Remarks  : Returns null until the target bow count has been reached.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Builds the record of the completed practice, or null if it is not completed.
  BowSession? buildCompletedSession() {
    // 시작·종료 시각을 지역 변수로 옮겨 null 여부를 한 번에 확인한다.
    final startedAt = _startedAt;
    // 종료 시각
    final endedAt = _endedAt;
    // 완료 전이면 기록을 만들 수 없다.
    if (!isCompleted || startedAt == null || endedAt == null) {
      // 기록 없음
      return null;
    }
    // 완료한 수행 기록을 만든다.
    return BowSession(
      // 종료 시각의 마이크로초 값을 식별자로 쓴다.
      id: endedAt.microsecondsSinceEpoch.toString(),
      // 시작 시각
      startedAt: startedAt,
      // 종료 시각
      endedAt: endedAt,
      // 일시정지를 뺀 수행 시간(초)
      activeDurationSeconds: _activeElapsed.inSeconds,
      // 절 수
      bowCount: _count,
    );
  }

  @override
  void dispose() {
    // 타이머를 멈춘다.
    _stopTimer();
    // 화면 켜짐 유지를 해제한다.
    _disableWakeLock();
    // 부모 클래스 정리를 이어서 한다.
    super.dispose();
  }

  // 준비 카운트다운을 진행하고, 끝나면 절을 세는 단계로 넘어간다.
  void _advancePreparation(Duration elapsed) {
    // 준비 시간에 흐른 시간을 더한다.
    _preparationElapsed += elapsed;
    // 아직 준비 시간이 남았으면 여기서 끝낸다.
    if (_preparationElapsed < _preparationDuration) {
      // 계속 준비 중
      return;
    }
    // 준비 시간을 넘긴 만큼은 수행 시간으로 넘긴다.
    final overflow = _preparationElapsed - _preparationDuration;
    // 세는 단계로 들어간다(첫 절은 간격이 지난 뒤 1배로 센다).
    _enterRunning();
    // 넘친 시간을 수행 시간과 간격에 반영한다.
    _advanceRunning(overflow);
  }

  // 수행 시간을 늘리고, 간격이 지날 때마다 1배를 센다.
  void _advanceRunning(Duration elapsed) {
    // 실제 수행 시간을 늘린다.
    _activeElapsed += elapsed;
    // 간격 시간에 흐른 시간을 더한다.
    _intervalElapsed += elapsed;
    // 간격이 지날 때마다 1배를 센다(긴 지연 시 여러 배를 놓치지 않도록 반복).
    while (_phase == CounterPhase.running &&
        _intervalElapsed >= _intervalDuration) {
      // 지난 간격만큼 뺀다.
      _intervalElapsed -= _intervalDuration;
      // 1배를 센다.
      _countBow();
    }
  }

  // 절을 세는 단계로 들어간다.
  void _enterRunning() {
    // 세는 단계로 바꾼다.
    _phase = CounterPhase.running;
    // 준비 시간을 지운다.
    _preparationElapsed = Duration.zero;
    // 처음 시작할 때만 시작 시각을 기록한다(이어서 할 때는 유지).
    _startedAt ??= _now();
  }

  // 1배를 세고 알림을 내며, 108배면 완료 처리한다.
  void _countBow() {
    // 절 수를 늘린다.
    _count++;
    // 목표 절 수에 도달했는지 확인한다.
    final isFinalBow = _count >= CounterRules.targetBowCount;
    // 소리·진동 알림을 보낸다(기다리지 않고 바로 다음 처리를 한다).
    unawaited(_notifyBow(isFinalBow: isFinalBow));
    // 108배면 완료 처리한다.
    if (isFinalBow) {
      // 완료 단계로 넘어간다.
      _complete();
    }
  }

  // 108배를 마친 상태로 바꾸고 화면 켜짐 유지를 해제한다.
  void _complete() {
    // 완료 단계로 바꾼다.
    _phase = CounterPhase.completed;
    // 종료 시각을 기록한다.
    _endedAt = _now();
    // 남은 간격 시간을 지운다.
    _intervalElapsed = Duration.zero;
    // 타이머를 멈춘다.
    _stopTimer();
    // 화면 켜짐 유지를 해제한다.
    _disableWakeLock();
  }

  // 알림 서비스를 호출하고, 기기 오류가 나도 카운트는 계속되도록 기록만 남긴다.
  Future<void> _notifyBow({required bool isFinalBow}) async {
    // 기기에서 소리·진동 호출이 실패할 수 있다.
    try {
      // 선택된 방식으로 알린다.
      await _feedbackService.notifyBow(
        _alertMode,
        bellSound: _bellSound,
        isFinalBow: isFinalBow,
      );
    } on PlatformException catch (error) {
      // 실패한 작업과 절 수를 남긴다.
      debugPrint('[CounterController] $_count배 알림 실패: $error');
    }
  }

  // 미리 듣기를 재생하고, 기기 오류가 나도 설정 변경은 계속되도록 기록만 남긴다.
  Future<void> _previewBell(BellSound bellSound) async {
    // 기기에서 소리 재생이 실패할 수 있다.
    try {
      // 한 번 울린다.
      await _feedbackService.previewBell(bellSound);
    } on PlatformException catch (error) {
      // 실패한 소리를 남긴다.
      debugPrint('[CounterController] ${bellSound.name} 미리 듣기 실패: $error');
    }
  }

  // 화면 켜짐 유지를 켠다(이미 켜져 있으면 다시 호출하지 않는다).
  void _enableWakeLock() {
    // 이미 켜져 있으면 끝낸다.
    if (_isWakeLockEnabled) {
      // 중복 호출 방지
      return;
    }
    // 켜진 상태로 표시한다.
    _isWakeLockEnabled = true;
    // 플러그인을 호출한다.
    unawaited(_runWakeLockCall(_wakeLockService.enable, 'enable'));
  }

  // 화면 켜짐 유지를 끈다(이미 꺼져 있으면 다시 호출하지 않는다).
  void _disableWakeLock() {
    // 이미 꺼져 있으면 끝낸다.
    if (!_isWakeLockEnabled) {
      // 중복 호출 방지
      return;
    }
    // 꺼진 상태로 표시한다.
    _isWakeLockEnabled = false;
    // 플러그인을 호출한다.
    unawaited(_runWakeLockCall(_wakeLockService.disable, 'disable'));
  }

  // 화면 켜짐 플러그인 호출 실패를 기록한다(카운트 동작은 막지 않는다).
  Future<void> _runWakeLockCall(
    Future<void> Function() wakeLockCall,
    String operationName,
  ) async {
    // 플랫폼 호출이 실패할 수 있다.
    try {
      // 실제 플러그인 호출
      await wakeLockCall();
    } on PlatformException catch (error) {
      // 어떤 작업이 실패했는지 남긴다.
      debugPrint('[CounterController] 화면 켜짐 $operationName 실패: $error');
    }
  }

  // 주기 타이머를 시작한다.
  void _startTimer() {
    // 테스트에서는 타이머를 쓰지 않거나, 이미 돌고 있으면 끝낸다.
    if (!_isTimerEnabled || _tickTimer != null) {
      // 시작할 필요 없음
      return;
    }
    // 경과 시간 측정 기준 시각을 지금으로 잡는다.
    _lastTickAt = _now();
    // 정해진 주기마다 실제로 흐른 시간만큼 tick()을 부른다.
    _tickTimer = Timer.periodic(CounterRules.tickInterval, (_) {
      // 현재 시각
      final currentTime = _now();
      // 지난 호출 이후 흐른 시간(기기 시계를 뒤로 돌린 경우 0으로 본다)
      final elapsed = currentTime.difference(_lastTickAt ?? currentTime);
      // 다음 측정 기준 시각
      _lastTickAt = currentTime;
      // 흐른 시간만큼 상태를 진행한다.
      tick(elapsed.isNegative ? Duration.zero : elapsed);
    });
  }

  // 주기 타이머를 멈춘다.
  void _stopTimer() {
    // 타이머를 취소한다.
    _tickTimer?.cancel();
    // 타이머 참조를 지운다.
    _tickTimer = null;
    // 측정 기준 시각을 지운다.
    _lastTickAt = null;
  }
}
