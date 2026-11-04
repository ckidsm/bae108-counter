import 'package:bae108_counter/controllers/counter_controller.dart';
import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/models/count_mode.dart';
import 'package:bae108_counter/models/counter_phase.dart';
import 'package:bae108_counter/models/counter_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_services.dart';

// 테스트에서 고정해 쓰는 현재 시각
final DateTime _fixedNow = DateTime(2026, 11, 4, 14, 0);
// 1초
const Duration _oneSecond = Duration(seconds: 1);
// 테스트용 자동 간격(초)
const int _intervalSeconds = 10;

void main() {
  // 가짜 알림 서비스
  late FakeBowFeedbackService feedbackService;
  // 가짜 화면 켜짐 서비스
  late FakeWakeLockService wakeLockService;

  // 지정한 방식으로 타이머 없이 동작하는 컨트롤러를 만든다.
  CounterController createController({
    CountMode countMode = CountMode.tap,
    AlertMode alertMode = AlertMode.bell,
  }) {
    // tick()을 직접 호출하도록 내부 타이머를 끈다.
    return CounterController(
      feedbackService: feedbackService,
      wakeLockService: wakeLockService,
      settings: CounterSettings(
        countMode: countMode,
        intervalSeconds: _intervalSeconds,
        alertMode: alertMode,
      ),
      clock: () => _fixedNow,
      isTimerEnabled: false,
    );
  }

  // 자동 모드에서 준비 카운트다운을 끝낸 상태로 만든다.
  CounterController createRunningAutoController() {
    // 자동 모드 컨트롤러
    final controller = createController(countMode: CountMode.auto);
    // 시작하면 준비 단계가 된다.
    controller.start();
    // 준비 시간만큼 진행해 세는 단계로 넘긴다.
    controller.tick(const Duration(seconds: CounterRules.preparationSeconds));
    // 준비가 끝난 컨트롤러
    return controller;
  }

  setUp(() {
    // 테스트마다 새 가짜 서비스를 만든다.
    feedbackService = FakeBowFeedbackService();
    // 테스트마다 새 가짜 서비스를 만든다.
    wakeLockService = FakeWakeLockService();
  });

  group('직접 탭', () {
    test('tapCircle_tapModeIdle_incrementsCountAndStartsRunning', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tapCircle();

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 1);
      expect(controller.phase, CounterPhase.running);
      expect(controller.startedAt, _fixedNow);
      expect(wakeLockService.isEnabled, isTrue);
    });

    test('tick_tapModeRunning_doesNotCountButTracksActiveTime', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();
      controller.start();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: 30));

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 0);
      expect(controller.activeElapsed, const Duration(seconds: 30));
    });

    test('start_tapModeFromZero_skipsPreparation', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.start();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.running);
    });
  });

  group('자동 간격 준비 카운트다운', () {
    test('start_autoModeFromZero_entersPreparationAtTenSeconds', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController(countMode: CountMode.auto);

      // 실행: 테스트 대상 동작을 수행한다.
      controller.start();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.preparing);
      expect(
        controller.preparationRemainingSeconds,
        CounterRules.preparationSeconds,
      );
      expect(wakeLockService.isEnabled, isTrue);
    });

    test('tick_preparationOneSecondElapsed_decreasesRemainingByOne', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController(countMode: CountMode.auto);
      controller.start();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(_oneSecond);

      // 검증: 기대 결과를 확인한다.
      expect(controller.preparationRemainingSeconds, 9);
    });

    test('tick_preparationNineSecondsElapsed_showsOneSecondLeft', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController(countMode: CountMode.auto);
      controller.start();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: 9));

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.preparing);
      expect(controller.preparationRemainingSeconds, 1);
    });

    test('tick_preparationFinished_startsRunningAtZeroBows', () {
      // 준비 및 실행: 대상을 만들고 동작을 수행한다.
      final controller = createRunningAutoController();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.running);
      expect(controller.count, 0);
      expect(controller.startedAt, _fixedNow);
      expect(controller.activeElapsed, Duration.zero);
    });

    test('tapCircle_duringPreparation_skipsPreparationAndCountsOne', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController(countMode: CountMode.auto);
      controller.start();
      controller.tick(const Duration(seconds: 3));

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tapCircle();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.running);
      expect(controller.count, 1);
    });
  });

  group('자동 간격 카운트', () {
    test('tick_autoModeIntervalElapsed_incrementsCountWithFeedback', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: _intervalSeconds));

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 1);
      expect(feedbackService.calls, hasLength(1));
      expect(feedbackService.calls.single.alertMode, AlertMode.bell);
      expect(feedbackService.calls.single.isFinalBow, isFalse);
    });

    test('tick_autoModeBeforeInterval_doesNotCount', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: _intervalSeconds - 1));

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 0);
      expect(controller.nextBowRemainingSeconds, 1);
    });

    test('tick_autoModeLongDelay_countsEveryElapsedInterval', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: _intervalSeconds * 3));

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 3);
    });

    test('tapCircle_autoModeRunning_incrementsAndRestartsInterval', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();
      controller.tick(const Duration(seconds: 7));

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tapCircle();
      controller.tick(const Duration(seconds: 7));

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 1);
      expect(controller.nextBowRemainingSeconds, 3);
    });

    test('innerRingProgress_autoModeHalfInterval_returnsHalf', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(const Duration(seconds: _intervalSeconds ~/ 2));

      // 검증: 기대 결과를 확인한다.
      expect(controller.innerRingProgress, closeTo(0.5, 0.0001));
    });
  });

  group('일시정지와 이어서', () {
    test('pause_whileRunning_stopsCountingAndKeepsWakeLock', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.pause();
      controller.tick(const Duration(seconds: _intervalSeconds * 2));

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.paused);
      expect(controller.count, 0);
      expect(wakeLockService.isEnabled, isTrue);
    });

    test('start_resumeWithCountedBows_skipsPreparation', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();
      controller.tick(const Duration(seconds: _intervalSeconds));
      controller.pause();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.start();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.running);
      expect(controller.count, 1);
    });

    test('toggleStartPause_whileRunning_pauses', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();
      controller.start();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.toggleStartPause();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.paused);
    });
  });

  group('108배 완료', () {
    test('tapCircle_reachesTarget_completesAndReleasesWakeLock', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      for (
        var bowIndex = 0;
        bowIndex < CounterRules.targetBowCount;
        bowIndex++
      ) {
        controller.tapCircle();
      }

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, CounterRules.targetBowCount);
      expect(controller.phase, CounterPhase.completed);
      expect(controller.endedAt, _fixedNow);
      expect(wakeLockService.isEnabled, isFalse);
      expect(feedbackService.calls.last.isFinalBow, isTrue);
      expect(
        feedbackService.calls.where((call) => call.isFinalBow),
        hasLength(1),
      );
    });

    test('tick_autoModeReachesTarget_stopsAtTarget', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tick(
        const Duration(
          seconds: _intervalSeconds * (CounterRules.targetBowCount + 5),
        ),
      );

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, CounterRules.targetBowCount);
      expect(controller.isCompleted, isTrue);
    });

    test('tapCircle_afterCompletion_doesNotCount', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();
      for (
        var bowIndex = 0;
        bowIndex < CounterRules.targetBowCount;
        bowIndex++
      ) {
        controller.tapCircle();
      }

      // 실행: 테스트 대상 동작을 수행한다.
      controller.tapCircle();

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, CounterRules.targetBowCount);
    });

    test('buildCompletedSession_afterCompletion_returnsRecord', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();
      controller.start();
      controller.tick(const Duration(minutes: 30));
      for (
        var bowIndex = 0;
        bowIndex < CounterRules.targetBowCount;
        bowIndex++
      ) {
        controller.tapCircle();
      }

      // 실행: 테스트 대상 동작을 수행한다.
      final session = controller.buildCompletedSession();

      // 검증: 기대 결과를 확인한다.
      expect(session, isNotNull);
      expect(session!.bowCount, CounterRules.targetBowCount);
      expect(
        session.activeDurationSeconds,
        const Duration(minutes: 30).inSeconds,
      );
      expect(session.startedAt, _fixedNow);
    });

    test('buildCompletedSession_beforeCompletion_returnsNull', () {
      // 준비 및 실행: 대상을 만들고 동작을 수행한다.
      final controller = createController();
      controller.tapCircle();

      // 검증: 기대 결과를 확인한다.
      expect(controller.buildCompletedSession(), isNull);
    });
  });

  group('처음부터', () {
    test('reset_afterProgress_clearsStateAndReleasesWakeLock', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();
      controller.tick(const Duration(seconds: _intervalSeconds * 2));

      // 실행: 테스트 대상 동작을 수행한다.
      controller.reset();

      // 검증: 기대 결과를 확인한다.
      expect(controller.count, 0);
      expect(controller.phase, CounterPhase.idle);
      expect(controller.startedAt, isNull);
      expect(controller.activeElapsed, Duration.zero);
      expect(wakeLockService.isEnabled, isFalse);
    });

    test('start_autoModeAfterReset_entersPreparationAgain', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createRunningAutoController();
      controller.tick(const Duration(seconds: _intervalSeconds));
      controller.reset();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.start();

      // 검증: 기대 결과를 확인한다.
      expect(controller.phase, CounterPhase.preparing);
    });
  });

  group('설정 변경', () {
    test('setIntervalSeconds_outOfRange_clampsToAllowedRange', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.setIntervalSeconds(1);
      final shortest = controller.intervalSeconds;
      controller.setIntervalSeconds(999);
      final longest = controller.intervalSeconds;

      // 검증: 기대 결과를 확인한다.
      expect(shortest, CounterRules.minimumIntervalSeconds);
      expect(longest, CounterRules.maximumIntervalSeconds);
    });

    test('setIntervalSeconds_notOnStep_roundsToFiveSeconds', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.setIntervalSeconds(62);

      // 검증: 기대 결과를 확인한다.
      expect(controller.intervalSeconds, 60);
    });

    test('setCountMode_whileRunning_isIgnored', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();
      controller.start();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.setCountMode(CountMode.auto);

      // 검증: 기대 결과를 확인한다.
      expect(controller.countMode, CountMode.tap);
    });

    test('setAlertMode_vibration_usesVibrationForNextBow', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.setAlertMode(AlertMode.vibration);
      controller.tapCircle();

      // 검증: 기대 결과를 확인한다.
      expect(feedbackService.calls.single.alertMode, AlertMode.vibration);
    });

    test('settings_afterChanges_reflectsCurrentOptions', () {
      // 준비: 테스트 조건을 만든다.
      final controller = createController();

      // 실행: 테스트 대상 동작을 수행한다.
      controller.setCountMode(CountMode.auto);
      controller.setIntervalSeconds(20);
      controller.setAlertMode(AlertMode.silent);

      // 검증: 기대 결과를 확인한다.
      expect(controller.settings.countMode, CountMode.auto);
      expect(controller.settings.intervalSeconds, 20);
      expect(controller.settings.alertMode, AlertMode.silent);
    });
  });
}
