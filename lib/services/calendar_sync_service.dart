import '../models/bow_session.dart';
import '../models/calendar_target.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Describes why a calendar operation failed.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 캘린더 작업이 실패한 이유.
enum CalendarSyncFailure {
  // 사용자가 캘린더 권한을 거부했다.
  /// The user denied calendar access.
  permissionDenied,

  // 플랫폼이 요청을 처리하지 못했다.
  /// The platform reported an error.
  platformError,
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Signals that a calendar operation could not be completed.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 캘린더 작업 실패 예외.
class CalendarSyncException implements Exception {
  /// Creates an exception for [failure] with a diagnostic [message].
  const CalendarSyncException(this.failure, this.message);

  /// Why the operation failed.
  final CalendarSyncFailure failure;

  /// A diagnostic message for logs; never shown to the user.
  final String message;

  @override
  String toString() => 'CalendarSyncException(${failure.name}): $message';
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds the localized text written into a calendar event.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 캘린더 일정에 들어갈 번역된 제목과 설명.
class CalendarEventText {
  /// Creates the event text.
  const CalendarEventText({required this.title, required this.description});

  /// The event title.
  final String title;

  /// The event description, such as the memo.
  final String description;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts reading device calendars and adding practice events to them.
 Remarks  : Lets tests replace the device calendar plugin with a fake.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 기기 캘린더 목록을 읽고 수행 기록 일정을 추가하는 서비스 계약.
abstract interface class CalendarSyncService {
  /// Asks for calendar access when needed.
  ///
  /// Throws a [CalendarSyncException] when access is denied.
  Future<void> ensureAccess();

  /// Loads the calendars that accept new events.
  ///
  /// Throws a [CalendarSyncException] when the calendars cannot be read.
  Future<List<CalendarTarget>> loadWritableCalendars();

  /// Adds [session] to [calendar] as an event described by [text].
  ///
  /// Throws a [CalendarSyncException] when the event cannot be created.
  Future<void> addPracticeEvent(
    BowSession session,
    CalendarTarget calendar,
    CalendarEventText text,
  );
}
