import 'dart:async';

import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/models/bell_sound.dart';
import 'package:bae108_counter/models/bow_session.dart';
import 'package:bae108_counter/models/calendar_target.dart';
import 'package:bae108_counter/models/counter_settings.dart';
import 'package:bae108_counter/services/bow_feedback_service.dart';
import 'package:bae108_counter/services/calendar_sync_service.dart';
import 'package:bae108_counter/services/wake_lock_service.dart';
import 'package:bae108_counter/services/watch_sync_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Records one feedback call made by the controller.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 컨트롤러가 요청한 알림 1건.
class RecordedFeedback {
  /// Creates a recorded call.
  const RecordedFeedback(
    this.alertMode, {
    required this.bellSound,
    required this.isFinalBow,
  });

  /// The requested feedback.
  final AlertMode alertMode;

  /// The bell sound requested with the feedback.
  final BellSound bellSound;

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

  /// The bell sounds previewed in the order they were played.
  final List<BellSound> previews = <BellSound>[];

  @override
  Future<void> notifyBow(
    AlertMode alertMode, {
    required BellSound bellSound,
    required bool isFinalBow,
  }) async {
    // 호출 내용을 기록한다.
    calls.add(
      RecordedFeedback(alertMode, bellSound: bellSound, isFinalBow: isFinalBow),
    );
  }

  @override
  Future<void> previewBell(BellSound bellSound) async {
    // 미리 듣기 요청을 기록한다.
    previews.add(bellSound);
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

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Records one calendar event added through the fake calendar service.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 가짜 캘린더에 추가된 일정 1건.
class RecordedCalendarEvent {
  /// Creates a recorded event.
  const RecordedCalendarEvent(this.session, this.calendar, this.text);

  /// The practice that was added.
  final BowSession session;

  /// The calendar the event was added to.
  final CalendarTarget calendar;

  /// The event title and description.
  final CalendarEventText text;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Replaces the device calendar plugin with configurable in-memory behavior.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 기기 캘린더 대신 메모리에서 동작하는 가짜 캘린더 서비스.
class FakeCalendarSyncService implements CalendarSyncService {
  /// Creates the fake with the given writable [calendars].
  FakeCalendarSyncService({this.calendars = const <CalendarTarget>[]});

  /// The calendars returned by [loadWritableCalendars].
  List<CalendarTarget> calendars;

  /// When set, every call fails with this reason.
  CalendarSyncFailure? failure;

  /// The events added so far.
  final List<RecordedCalendarEvent> addedEvents = <RecordedCalendarEvent>[];

  @override
  Future<void> ensureAccess() async {
    // 실패하도록 설정했으면 예외를 던진다.
    _throwIfFailing();
  }

  @override
  Future<List<CalendarTarget>> loadWritableCalendars() async {
    // 실패하도록 설정했으면 예외를 던진다.
    _throwIfFailing();
    // 설정된 캘린더 목록
    return calendars;
  }

  @override
  Future<void> addPracticeEvent(
    BowSession session,
    CalendarTarget calendar,
    CalendarEventText text,
  ) async {
    // 실패하도록 설정했으면 예외를 던진다.
    _throwIfFailing();
    // 추가된 일정을 기록한다.
    addedEvents.add(RecordedCalendarEvent(session, calendar, text));
  }

  // 설정된 실패 사유가 있으면 예외를 던진다.
  void _throwIfFailing() {
    // 실패 사유
    final configuredFailure = failure;
    // 실패하도록 설정했으면 예외
    if (configuredFailure != null) {
      // 테스트용 예외
      throw CalendarSyncException(configuredFailure, 'fake failure');
    }
  }
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Replaces the Apple Watch bridge with an in-memory queue.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 워치 브리지 대신 메모리에서 동작하는 가짜 워치 연동 서비스.
class FakeWatchSyncService implements WatchSyncService {
  /// The settings sent to the watch, in order.
  final List<CounterSettings> sentSettings = <CounterSettings>[];

  /// The records waiting to be taken, as if delivered by the watch.
  final List<BowSession> pendingSessions = <BowSession>[];

  // 새 기록 도착 알림 스트림
  final StreamController<void> _sessionsAvailable =
      StreamController<void>.broadcast();

  /// Simulates the watch delivering [sessions] while the app is running.
  void deliver(List<BowSession> sessions) {
    // 대기열에 넣는다.
    pendingSessions.addAll(sessions);
    // 도착을 알린다.
    _sessionsAvailable.add(null);
  }

  @override
  Future<void> sendSettings(CounterSettings settings) async {
    // 보낸 설정을 기록한다.
    sentSettings.add(settings);
  }

  @override
  Future<List<BowSession>> takeCompletedSessions() async {
    // 대기열을 복사해 돌려주고 비운다.
    final sessions = List<BowSession>.of(pendingSessions);
    // 비운다.
    pendingSessions.clear();
    // 돌려준다.
    return sessions;
  }

  @override
  Stream<void> get sessionsAvailable => _sessionsAvailable.stream;
}
