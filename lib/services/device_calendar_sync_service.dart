import 'package:device_calendar/device_calendar.dart';

import '../models/bow_session.dart';
import '../models/calendar_target.dart';
import 'calendar_sync_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Writes practice events to device calendars through device_calendar.
 Remarks  : Google accounts signed in on the device appear as device calendars,
            so events reach Google Calendar through the system sync.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// device_calendar 플러그인으로 기기 캘린더(Google 계정 포함)에 일정을 추가한다.
final class DeviceCalendarSyncService implements CalendarSyncService {
  /// Creates the service with its own plugin instance.
  DeviceCalendarSyncService() : _plugin = DeviceCalendarPlugin();

  // 기기 캘린더 플러그인
  final DeviceCalendarPlugin _plugin;

  @override
  Future<void> ensureAccess() async {
    // 이미 권한이 있는지 확인한다.
    final currentPermission = await _plugin.hasPermissions();
    // 권한이 있으면 끝낸다.
    if (currentPermission.data == true) {
      // 권한 있음
      return;
    }
    // 권한을 요청한다.
    final requestedPermission = await _plugin.requestPermissions();
    // 거부했으면 예외를 던진다.
    if (requestedPermission.data != true) {
      // 거부 사유와 플랫폼 오류를 함께 남긴다.
      throw CalendarSyncException(
        CalendarSyncFailure.permissionDenied,
        '캘린더 권한 거부: ${_describeErrors(requestedPermission)}',
      );
    }
  }

  @override
  Future<List<CalendarTarget>> loadWritableCalendars() async {
    // 권한부터 확인한다.
    await ensureAccess();
    // 기기 캘린더 목록을 읽는다.
    final result = await _plugin.retrieveCalendars();
    // 읽기에 실패하면 예외를 던진다.
    final calendars = result.data;
    // 데이터가 없으면 실패로 본다.
    if (calendars == null) {
      // 플랫폼 오류를 남긴다.
      throw CalendarSyncException(
        CalendarSyncFailure.platformError,
        '캘린더 목록 읽기 실패: ${_describeErrors(result)}',
      );
    }
    // 쓰기 가능한 캘린더만 골라 앱 모델로 바꾼다.
    return calendars
        // 읽기 전용이 아니고 식별자가 있는 캘린더
        .where((calendar) => calendar.isReadOnly != true && calendar.id != null)
        // 앱 모델로 변환
        .map(
          (calendar) => CalendarTarget(
            // 식별자
            id: calendar.id!,
            // 이름(없으면 빈 문자열)
            name: calendar.name ?? '',
            // 계정 이름(없으면 빈 문자열)
            accountName: calendar.accountName ?? '',
          ),
        )
        // 목록으로 만든다.
        .toList();
  }

  @override
  Future<void> addPracticeEvent(
    BowSession session,
    CalendarTarget calendar,
    CalendarEventText text,
  ) async {
    // 권한부터 확인한다.
    await ensureAccess();
    // 일정은 절대 시각만 맞으면 되므로 UTC 기준 TZDateTime으로 만든다(캘린더 앱이 기기 시간대로 표시한다).
    final event = Event(
      // 기록할 캘린더
      calendar.id,
      // 제목
      title: text.title,
      // 설명(메모 등)
      description: text.description,
      // 시작 시각
      start: TZDateTime.from(session.startedAt, UTC),
      // 종료 시각
      end: TZDateTime.from(session.endedAt, UTC),
    );
    // 일정을 만든다.
    final result = await _plugin.createOrUpdateEvent(event);
    // 결과가 없거나 실패면 예외를 던진다.
    if (result == null || !result.isSuccess) {
      // 플랫폼 오류를 남긴다.
      throw CalendarSyncException(
        CalendarSyncFailure.platformError,
        '캘린더 일정 추가 실패: ${result == null ? '결과 없음' : _describeErrors(result)}',
      );
    }
  }

  // 플러그인 결과의 오류 목록을 한 줄 문자열로 만든다.
  String _describeErrors(Result<Object?> result) {
    // "코드: 메시지" 형식으로 이어 붙인다.
    return result.errors
        // 각 오류를 문자열로
        .map((error) => '${error.errorCode}: ${error.errorMessage}')
        // 쉼표로 연결
        .join(', ');
  }
}
