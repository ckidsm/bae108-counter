/*────────────────────────────────────────────────────────────────────────
 Purpose  : Identifies the device calendar that receives practice events.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 기록 일정을 추가할 기기 캘린더.
class CalendarTarget {
  /// Creates a calendar reference.
  const CalendarTarget({
    required this.id,
    required this.name,
    required this.accountName,
  });

  // JSON 키: 캘린더 식별자
  static const String _idKey = 'id';
  // JSON 키: 캘린더 이름
  static const String _nameKey = 'name';
  // JSON 키: 계정 이름
  static const String _accountNameKey = 'accountName';

  /// The platform calendar identifier.
  final String id;

  /// The calendar's display name.
  final String name;

  /// The account that owns the calendar, such as a Google account e-mail.
  final String accountName;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Restores a calendar reference from JSON.
   Remarks  : Returns null when required fields are missing.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Restores a calendar reference from [json], or null when it is invalid.
  static CalendarTarget? tryFromJson(Object? json) {
    // Map이 아니면 복원할 수 없다.
    if (json is! Map<String, dynamic>) {
      // 복원 불가
      return null;
    }
    // 식별자
    final id = json[_idKey];
    // 이름
    final name = json[_nameKey];
    // 둘 중 하나라도 문자열이 아니면 복원할 수 없다.
    if (id is! String || name is! String) {
      // 복원 불가
      return null;
    }
    // 복원한 캘린더 정보
    return CalendarTarget(
      // 식별자
      id: id,
      // 이름
      name: name,
      // 계정 이름(없으면 빈 문자열)
      accountName: json[_accountNameKey] as String? ?? '',
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Converts the calendar reference to a JSON-compatible map.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Converts the calendar reference to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    // 세 값을 저장한다.
    return <String, dynamic>{
      // 식별자
      _idKey: id,
      // 이름
      _nameKey: name,
      // 계정 이름
      _accountNameKey: accountName,
    };
  }
}
