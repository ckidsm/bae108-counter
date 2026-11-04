/*────────────────────────────────────────────────────────────────────────
 Purpose  : Represents one completed 108-bow practice record.
 Remarks  : Duration excludes paused time and the preparation countdown.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 완료한 108배 수행 1회의 기록.
class BowSession {
  /// Creates a practice record.
  const BowSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.activeDurationSeconds,
    required this.bowCount,
    this.memo = '',
  });

  // JSON 키: 기록 식별자
  static const String _idKey = 'id';
  // JSON 키: 시작 시각
  static const String _startedAtKey = 'startedAt';
  // JSON 키: 종료 시각
  static const String _endedAtKey = 'endedAt';
  // JSON 키: 실제 수행 시간(초)
  static const String _activeDurationSecondsKey = 'activeDurationSeconds';
  // JSON 키: 절 수
  static const String _bowCountKey = 'bowCount';
  // JSON 키: 메모
  static const String _memoKey = 'memo';

  /// The unique identifier of the record.
  final String id;

  /// The time the first bow started counting.
  final DateTime startedAt;

  /// The time the final bow was counted.
  final DateTime endedAt;

  /// The practice time excluding pauses, in seconds.
  final int activeDurationSeconds;

  /// The number of bows completed.
  final int bowCount;

  /// The optional one-line memo written after the practice.
  final String memo;

  /// The practice time excluding pauses.
  Duration get activeDuration => Duration(seconds: activeDurationSeconds);

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns a copy of the record with a different memo.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns a copy of this record with [memo] replaced.
  BowSession copyWithMemo(String memo) {
    // 메모만 바꾸고 나머지 값은 그대로 복사한다.
    return BowSession(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt,
      activeDurationSeconds: activeDurationSeconds,
      bowCount: bowCount,
      memo: memo,
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Restores a record from a JSON map.
   Remarks  : Throws FormatException when a required field is missing or invalid.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Restores a record from [json].
  ///
  /// Throws a [FormatException] when a required field is missing or invalid.
  factory BowSession.fromJson(Map<String, dynamic> json) {
    // 필수 값의 형식이 맞지 않으면 어떤 필드가 문제인지 알 수 있게 예외를 던진다.
    try {
      // 저장된 각 필드를 원래 타입으로 바꿔 기록을 만든다.
      return BowSession(
        // 식별자 문자열
        id: json[_idKey] as String,
        // ISO-8601 문자열을 시각으로 바꾼다.
        startedAt: DateTime.parse(json[_startedAtKey] as String),
        // ISO-8601 문자열을 시각으로 바꾼다.
        endedAt: DateTime.parse(json[_endedAtKey] as String),
        // 실제 수행 시간(초)
        activeDurationSeconds: json[_activeDurationSecondsKey] as int,
        // 절 수
        bowCount: json[_bowCountKey] as int,
        // 메모가 없던 예전 기록은 빈 문자열로 둔다.
        memo: json[_memoKey] as String? ?? '',
      );
    } on TypeError catch (error) {
      // 타입 오류를 저장 데이터 형식 오류로 바꿔 원인과 함께 다시 던진다.
      throw FormatException('BowSession JSON 필드 형식이 올바르지 않습니다: $error');
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Converts the record to a JSON-compatible map.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Converts the record to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    // 시각은 ISO-8601 문자열로 저장한다.
    return <String, dynamic>{
      // 식별자
      _idKey: id,
      // 시작 시각
      _startedAtKey: startedAt.toIso8601String(),
      // 종료 시각
      _endedAtKey: endedAt.toIso8601String(),
      // 실제 수행 시간(초)
      _activeDurationSecondsKey: activeDurationSeconds,
      // 절 수
      _bowCountKey: bowCount,
      // 메모
      _memoKey: memo,
    };
  }
}
