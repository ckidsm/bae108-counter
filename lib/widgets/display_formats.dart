import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the date-time patterns shown on screen.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 화면에 표시할 날짜·시각 형식.
abstract final class DisplayDatePatterns {
  // 상단 시계: 2026.11.04 (수) 14:32:05
  /// The live clock pattern, for example `2026.11.04 (수) 14:32:05`.
  static const String clock = 'yyyy.MM.dd (E) HH:mm:ss';

  // 기록 날짜: 2026.11.04 (수)
  /// The record date pattern, for example `2026.11.04 (수)`.
  static const String date = 'yyyy.MM.dd (E)';

  // 24시간 시각: 14:32
  /// The 24-hour time pattern, for example `14:32`.
  static const String time = 'HH:mm';

  // 1배 평균 초: 소수점 한 자리
  /// The pattern of the per-bow average seconds.
  static const String averageSeconds = '0.0';
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Formats durations and date-times into localized display text.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 시간·날짜를 화면용 문구로 바꾼다.
final class DisplayFormatter {
  /// Creates a formatter for the given localization.
  DisplayFormatter(this._localizations)
    : _clockFormat = DateFormat(
        DisplayDatePatterns.clock,
        _localizations.localeName,
      ),
      _dateFormat = DateFormat(
        DisplayDatePatterns.date,
        _localizations.localeName,
      ),
      _timeFormat = DateFormat(
        DisplayDatePatterns.time,
        _localizations.localeName,
      ),
      _averageFormat = NumberFormat(
        DisplayDatePatterns.averageSeconds,
        _localizations.localeName,
      );

  // 번역 문구
  final AppLocalizations _localizations;
  // 상단 시계 형식
  final DateFormat _clockFormat;
  // 기록 날짜 형식
  final DateFormat _dateFormat;
  // 24시간 시각 형식
  final DateFormat _timeFormat;
  // 평균 초 형식
  final NumberFormat _averageFormat;

  /// Formats [dateTime] as the live clock text.
  String formatClock(DateTime dateTime) => _clockFormat.format(dateTime);

  /// Formats [dateTime] as a record date.
  String formatDate(DateTime dateTime) => _dateFormat.format(dateTime);

  /// Formats [dateTime] as a 24-hour time.
  String formatTime(DateTime dateTime) => _timeFormat.format(dateTime);

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Formats a start and end time as "HH:mm → HH:mm".
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Formats [startedAt] and [endedAt] as a 24-hour time range.
  String formatTimeRange(DateTime startedAt, DateTime endedAt) {
    // 두 시각을 24시간 형식으로 바꿔 범위 문구에 넣는다.
    return _localizations.timeRange(formatTime(startedAt), formatTime(endedAt));
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Formats an average duration as seconds with one decimal place.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Formats [duration] as seconds with one decimal place.
  String formatAverageSeconds(Duration duration) {
    // 밀리초를 초 단위 실수로 바꾼다.
    final seconds = duration.inMilliseconds / Duration.millisecondsPerSecond;
    // 소수점 한 자리 문구로 만든다.
    return _localizations.averageSecondsValue(_averageFormat.format(seconds));
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Formats a duration as hours/minutes/seconds text, omitting zero parts.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Formats [duration] as "N시간 N분", "N분 N초", "N분" or "N초".
  String formatDuration(Duration duration) {
    // 시간 부분
    final hours = duration.inHours;
    // 시간을 뺀 분 부분
    final minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
    // 분을 뺀 초 부분
    final seconds = duration.inSeconds.remainder(Duration.secondsPerMinute);
    // 1시간 이상이면 시간과 분만 표시한다.
    if (hours > 0) {
      // N시간 N분
      return _localizations.durationHoursMinutes(hours, minutes);
    }
    // 1분 미만이면 초만 표시한다.
    if (minutes == 0) {
      // N초
      return _localizations.durationSeconds(seconds);
    }
    // 초가 0이면 분만 표시한다.
    if (seconds == 0) {
      // N분
      return _localizations.durationMinutes(minutes);
    }
    // N분 N초
    return _localizations.durationMinutesSeconds(minutes, seconds);
  }
}
