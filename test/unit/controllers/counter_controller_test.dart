import 'package:bae108_counter/controllers/counter_controller.dart';
import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/models/bell_sound.dart';
import 'package:bae108_counter/models/counter_phase.dart';
import 'package:bae108_counter/models/counter_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_services.dart';

// 테스트에서 고정해 쓰는 현재 시각
final DateTime _fixedNow = DateTime(2026, 11, 4, 14, 0);
// 테스트용 자동 간격(초)
const int _intervalSeconds = 10;
// 테스트용 자동 간격
const Duration _interval = Duration(seconds: _intervalSeconds);
// 준비 카운트다운 길이
const Duration _preparation = Duration(
  seconds: CounterRules.preparationSeconds,
);

void main() {
  // 가짜 알림 서비스
  late FakeBowFeedbackService feedbackService;
  // 가짜 화면 켜짐 서비스
  late FakeWakeLockService wakeLockService;

  // 타이머 없이 동작하는 컨트롤러를 만든다.
  CounterController createController({AlertMode alertMode = AlertMode.bell}) {
    // tick()을 직접 호출하도록 내부 타이머를 끈다.
    return CounterController(
      feedbackService: feedbackService,
      wakeLockService: wakeLockService,
      settings: CounterSettings(
        intervalSeconds: _intervalSeconds,
        alertMode: alertMode,
      ),
      now: () => _fixedNow,
      isTimerEnabled: false,
    );
  }

  // 시작해서 준비 카운트다운을 끝낸 컨트롤러를 만든다.
  CounterController createRunningController() {
    // 컨트롤러
    final controller = createController();
    // 시작하면 준비 단계가 된다.
    controller.start();
    // 준비 시간만큼 진행해 세는 단계로 넘긴다.
    controller.tick(_preparation);
    // 준비가 끝난 컨트롤러
    return controller;
  }

  // 108배를 모두 센 컨트롤러를 만든다.
  CounterController createCompletedController() {
    // 세는 중인 컨트롤러
    final controller = createRunningController();
    // 108번의 간격만큼 진행한다.
    controller.tick(_interval * CounterRules.targetBowCount);
    // 완료된 컨트롤러
    return controller;
  }

  setUp(() {
    // 테스트마다 새 가짜 서비스를 만든다.
    feedbackService = FakeBowFeedbackService();
    // 테스트마다 새 가짜 서비스를 만든다.
    wakeLockService = FakeWakeLockService();
  });

  group('시작과 준비 카운트다운', () {
    test('start_fromZero_entersPreparationAtTenSeconds', () {
      // 준비: 컨트롤러
      final controller = createController();

      // 실행: 시작한다.
      controller.start();

      // 검증: 10초 준비 단계가 되고 화면이 켜진다.
      expect(controller.phase, CounterPhase.preparing);
      expect(
        controller.preparationRemainingSeconds,
        CounterRules.preparationSeconds,
      );
      expect(wakeLockService.isEnabled, isTrue);
    });

    test('tick_preparationOneSecondElapsed_decreasesRemainingByOne', () {
      // 준비: 시작한 컨트롤러
      final controller = createController();
      controller.start();

      // 실행: 1초 진행한다.
      controller.tick(const Duration(seconds: 1));

      // 검증: 9초 남는다.
      expect(controller.preparationRemainingSeconds, 9);
    });

    test('tick_preparationFinished_startsRunningAtZeroBows', () {
      // 준비 및 실행: 준비 카운트다운을 끝낸다.
      final controller = createRunningController();

      // 검증: 0배에서 세기 시작하고 시작 시각이 기록된다.
      expect(controller.phase, CounterPhase.running);
      expect(controller.count, 0);
      expect(controller.startedAt, _fixedNow);
      expect(controller.activeElapsed, Duration.zero);
    });

    test('tick_beforePreparationEnds_doesNotCount', () {
      // 준비: 시작한 컨트롤러
      final controller = createController();
      controller.start();

      // 실행: 준비 시간보다 조금 덜 진행한다.
      controller.tick(_preparation - const Duration(milliseconds: 1));

      // 검증: 아직 준비 중이고 0배다.
      expect(controller.phase, CounterPhase.preparing);
      expect(controller.count, 0);
    });
  });

  group('간격 카운트', () {
    test('tick_intervalElapsed_incrementsCountWithFeedback', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 간격 하나만큼 진행한다.
      controller.tick(_interval);

      // 검증: 1배가 되고 알림이 한 번 간다.
      expect(controller.count, 1);
      expect(feedbackService.calls, hasLength(1));
      expect(feedbackService.calls.single.alertMode, AlertMode.bell);
      expect(feedbackService.calls.single.isFinalBow, isFalse);
    });

    test('tick_beforeInterval_doesNotCount', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 간격보다 1초 덜 진행한다.
      controller.tick(_interval - const Duration(seconds: 1));

      // 검증: 아직 0배이고 1초 남는다.
      expect(controller.count, 0);
      expect(controller.nextBowRemainingSeconds, 1);
    });

    test('tick_longDelay_countsEveryElapsedInterval', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 간격 세 개만큼 한 번에 진행한다.
      controller.tick(_interval * 3);

      // 검증: 3배를 놓치지 않고 센다.
      expect(controller.count, 3);
    });

    test('innerRingProgress_halfInterval_returnsHalf', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 간격의 절반만큼 진행한다.
      controller.tick(_interval ~/ 2);

      // 검증: 안쪽 링이 절반 찬다.
      expect(controller.innerRingProgress, closeTo(0.5, 0.0001));
    });
  });

  group('정지와 다시 시작', () {
    test('stop_whileRunning_keepsCountAndScreenOn', () {
      // 준비: 2배를 센 컨트롤러
      final controller = createRunningController();
      controller.tick(_interval * 2);

      // 실행: 정지하고 시간이 흐른다.
      controller.stop();
      controller.tick(_interval * 5);

      // 검증: 2배에서 멈추고 화면은 계속 켜져 있다.
      expect(controller.phase, CounterPhase.paused);
      expect(controller.count, 2);
      expect(wakeLockService.isEnabled, isTrue);
    });

    test('stop_duringPreparation_stopsCountdown', () {
      // 준비: 시작한 컨트롤러
      final controller = createController();
      controller.start();

      // 실행: 준비 중에 정지한다.
      controller.stop();

      // 검증: 정지 상태가 된다.
      expect(controller.phase, CounterPhase.paused);
    });

    test('start_afterStopWithBows_resumesWithoutPreparation', () {
      // 준비: 1배를 세고 정지한 컨트롤러
      final controller = createRunningController();
      controller.tick(_interval);
      controller.stop();

      // 실행: 다시 시작한다.
      controller.start();

      // 검증: 준비 없이 바로 이어서 센다.
      expect(controller.phase, CounterPhase.running);
      expect(controller.count, 1);
    });

    test('stop_whenIdle_isIgnored', () {
      // 준비: 대기 중인 컨트롤러
      final controller = createController();

      // 실행: 정지를 누른다.
      controller.stop();

      // 검증: 대기 상태 그대로다.
      expect(controller.phase, CounterPhase.idle);
    });
  });

  group('108배 완료', () {
    test('tick_reachesTarget_completesAndReleasesWakeLock', () {
      // 준비 및 실행: 108배를 모두 센다.
      final controller = createCompletedController();

      // 검증: 108배에서 멈추고 화면 켜짐이 해제되며 마지막 알림은 길게 간다.
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

    test('tick_pastTarget_stopsAtTarget', () {
      // 준비: 완료된 컨트롤러
      final controller = createCompletedController();

      // 실행: 시간이 더 흐른다.
      controller.tick(_interval * 5);

      // 검증: 108배를 넘지 않는다.
      expect(controller.count, CounterRules.targetBowCount);
    });

    test('start_afterCompletion_isIgnored', () {
      // 준비: 완료된 컨트롤러
      final controller = createCompletedController();

      // 실행: 시작을 누른다.
      controller.start();

      // 검증: 완료 상태 그대로다.
      expect(controller.phase, CounterPhase.completed);
    });

    test('buildCompletedSession_afterCompletion_returnsRecord', () {
      // 준비 및 실행: 완료된 컨트롤러에서 기록을 만든다.
      final session = createCompletedController().buildCompletedSession();

      // 검증: 108배, 실제 수행 시간(간격 x 108), 시작 시각이 담긴다.
      expect(session, isNotNull);
      expect(session!.bowCount, CounterRules.targetBowCount);
      expect(
        session.activeDurationSeconds,
        _intervalSeconds * CounterRules.targetBowCount,
      );
      expect(session.startedAt, _fixedNow);
    });

    test('buildCompletedSession_beforeCompletion_returnsNull', () {
      // 준비: 1배만 센 컨트롤러
      final controller = createRunningController();
      controller.tick(_interval);

      // 실행 및 검증: 기록을 만들 수 없다.
      expect(controller.buildCompletedSession(), isNull);
    });
  });

  group('처음부터', () {
    test('reset_afterProgress_clearsStateAndReleasesWakeLock', () {
      // 준비: 2배를 센 컨트롤러
      final controller = createRunningController();
      controller.tick(_interval * 2);

      // 실행: 처음부터.
      controller.reset();

      // 검증: 모든 값이 지워지고 화면 켜짐이 해제된다.
      expect(controller.count, 0);
      expect(controller.phase, CounterPhase.idle);
      expect(controller.startedAt, isNull);
      expect(controller.activeElapsed, Duration.zero);
      expect(wakeLockService.isEnabled, isFalse);
    });

    test('start_afterReset_entersPreparationAgain', () {
      // 준비: 1배를 세고 처음부터로 돌린 컨트롤러
      final controller = createRunningController();
      controller.tick(_interval);
      controller.reset();

      // 실행: 다시 시작한다.
      controller.start();

      // 검증: 다시 준비 카운트다운부터 한다.
      expect(controller.phase, CounterPhase.preparing);
    });
  });

  group('설정 변경', () {
    test('setIntervalSeconds_outOfRange_clampsToAllowedRange', () {
      // 준비: 컨트롤러
      final controller = createController();

      // 실행: 범위 밖 값을 넣는다.
      controller.setIntervalSeconds(1);
      final shortest = controller.intervalSeconds;
      controller.setIntervalSeconds(999);
      final longest = controller.intervalSeconds;

      // 검증: 5초~180초로 보정된다.
      expect(shortest, CounterRules.minimumIntervalSeconds);
      expect(longest, CounterRules.maximumIntervalSeconds);
    });

    test('setIntervalSeconds_notOnStep_roundsToFiveSeconds', () {
      // 준비: 컨트롤러
      final controller = createController();

      // 실행: 5초 단위가 아닌 값을 넣는다.
      controller.setIntervalSeconds(62);

      // 검증: 5초 단위로 반올림된다.
      expect(controller.intervalSeconds, 60);
    });

    test('setAlertMode_vibration_usesVibrationForNextBow', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 진동으로 바꾸고 1배를 센다.
      controller.setAlertMode(AlertMode.vibration);
      controller.tick(_interval);

      // 검증: 진동 알림이 간다.
      expect(feedbackService.calls.single.alertMode, AlertMode.vibration);
    });

    test('setBellSound_clear_previewsAndUsesItForNextBow', () {
      // 준비: 세는 중인 컨트롤러
      final controller = createRunningController();

      // 실행: 맑은 종으로 바꾸고 1배를 센다.
      controller.setBellSound(BellSound.clear);
      controller.tick(_interval);

      // 검증: 한 번 미리 들려주고, 다음 절에 맑은 종을 쓴다.
      expect(feedbackService.previews, <BellSound>[BellSound.clear]);
      expect(feedbackService.calls.single.bellSound, BellSound.clear);
      expect(controller.settings.bellSound, BellSound.clear);
    });

    test('setBellSound_sameSound_stillPreviews', () {
      // 준비: 기본(중저음) 컨트롤러
      final controller = createController();

      // 실행: 이미 고른 소리를 다시 누른다.
      controller.setBellSound(BellSound.deep);

      // 검증: 다시 들려준다.
      expect(feedbackService.previews, <BellSound>[BellSound.deep]);
    });

    test('settings_afterChanges_reflectsCurrentOptions', () {
      // 준비: 컨트롤러
      final controller = createController();

      // 실행: 간격과 알림 방식을 바꾼다.
      controller.setIntervalSeconds(20);
      controller.setAlertMode(AlertMode.silent);

      // 검증: 저장용 설정에 반영된다.
      expect(controller.settings.intervalSeconds, 20);
      expect(controller.settings.alertMode, AlertMode.silent);
    });
  });
}
