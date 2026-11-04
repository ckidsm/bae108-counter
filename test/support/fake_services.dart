import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/services/bow_feedback_service.dart';
import 'package:bae108_counter/services/wake_lock_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Records one feedback call made by the controller.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 컨트롤러가 요청한 알림 1건.
class RecordedFeedback {
  /// Creates a recorded call.
  const RecordedFeedback(this.alertMode, {required this.isFinalBow});

  /// The requested feedback.
  final AlertMode alertMode;

  /// Whether the call was for the final bow.
  final bool isFinalBow;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Replaces device sound and vibration with an in-memory call log.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 소리·진동 대신 호출 기록만 남기는 가짜 알림 서비스.
class FakeBowFeedbackService implements BowFeedbackService {
  /// The feedback calls in the order they were made.
  final List<RecordedFeedback> calls = <RecordedFeedback>[];

  @override
  Future<void> notifyBow(
    AlertMode alertMode, {
    required bool isFinalBow,
  }) async {
    // 호출 내용을 기록한다.
    calls.add(RecordedFeedback(alertMode, isFinalBow: isFinalBow));
  }

  @override
  Future<void> dispose() async {}
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Replaces the wake lock plugin with an in-memory state flag.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 플러그인 대신 켜짐 상태만 기억하는 가짜 화면 켜짐 서비스.
class FakeWakeLockService implements WakeLockService {
  /// Whether the screen is currently kept on.
  bool isEnabled = false;

  /// How many times [enable] was called.
  int enableCallCount = 0;

  @override
  Future<void> enable() async {
    // 켜짐으로 바꾼다.
    isEnabled = true;
    // 호출 횟수를 센다.
    enableCallCount++;
  }

  @override
  Future<void> disable() async {
    // 꺼짐으로 바꾼다.
    isEnabled = false;
  }
}
