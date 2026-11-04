import '../models/bow_session.dart';
import '../models/practice_statistics.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Calculates streaks, weekly check marks, and monthly totals from records.
 Remarks  : Pure calculation; the reference date is passed in so tests can control time.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 기록으로 연속 일수·주간 체크·월간 합계를 계산한다.
abstract final class PracticeStatisticsCalculator {
  // 한 주의 날 수
  static const int _daysPerWeek = 7;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Builds the full statistics snapshot for the history screen.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Builds the statistics of [sessions] relative to [today].
  static PracticeStatistics calculate(
    List<BowSession> sessions,
    DateTime today,
  ) {
    // 수행한 날짜(시각 제외) 집합을 만든다.
    final practiceDates = collectPracticeDates(sessions);
    // 이번 주 월요일~일요일 날짜를 만든다.
    final weekDates = weekDatesOf(today);
    // 이번 달에 끝난 기록만 고른다.
    final monthlySessions = sessions.where(
      // 같은 연도와 같은 달인지 확인한다.
      (session) =>
          session.endedAt.year == today.year &&
          session.endedAt.month == today.month,
    );
    // 계산 결과를 하나로 묶어 돌려준다.
    return PracticeStatistics(
      // 오늘(또는 어제)까지 이어진 연속 일수
      currentStreakDays: currentStreakDays(practiceDates, today),
      // 가장 길었던 연속 일수
      longestStreakDays: longestStreakDays(practiceDates),
      // 이번 주 날짜
      weekDates: weekDates,
      // 이번 주 각 날짜의 수행 여부
      completedWeekDays: weekDates.map(practiceDates.contains).toList(),
      // 이번 달 수행 횟수
      monthlySessionCount: monthlySessions.length,
      // 이번 달 절 수 합계
      monthlyBowCount: monthlySessions.fold<int>(
        0,
        // 각 기록의 절 수를 더한다.
        (total, session) => total + session.bowCount,
      ),
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Counts consecutive practice days ending today, or yesterday if today is empty.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Counts consecutive practice days ending on [today].
  ///
  /// The streak is still alive when the last practice was yesterday.
  static int currentStreakDays(Set<DateTime> practiceDates, DateTime today) {
    // 비교를 위해 오늘 날짜에서 시각을 뗀다.
    final todayDate = dateOnly(today);
    // 오늘 수행했으면 오늘부터, 아니면 어제부터 거꾸로 센다.
    var cursorDate = practiceDates.contains(todayDate)
        ? todayDate
        : _addDays(todayDate, -1);
    // 연속 일수
    var streakDays = 0;
    // 수행한 날이 이어지는 동안 하루씩 거슬러 올라간다.
    while (practiceDates.contains(cursorDate)) {
      // 연속 일수를 하나 늘린다.
      streakDays++;
      // 하루 전으로 이동한다.
      cursorDate = _addDays(cursorDate, -1);
    }
    // 계산한 연속 일수를 돌려준다.
    return streakDays;
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Finds the longest run of consecutive practice days.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Finds the longest run of consecutive days in [practiceDates].
  static int longestStreakDays(Set<DateTime> practiceDates) {
    // 날짜를 오래된 순으로 정렬한다.
    final sortedDates = practiceDates.toList()..sort();
    // 지금까지의 최장 연속 일수
    var longestDays = 0;
    // 현재 이어지고 있는 연속 일수
    var runningDays = 0;
    // 바로 앞 날짜
    DateTime? previousDate;
    // 날짜를 하나씩 확인한다.
    for (final date in sortedDates) {
      // 앞 날짜의 다음 날이면 연속을 이어 가고, 아니면 새로 시작한다.
      final isNextDay =
          previousDate != null && _addDays(previousDate, 1) == date;
      // 연속이면 1 늘리고, 끊겼으면 1부터 다시 센다.
      runningDays = isNextDay ? runningDays + 1 : 1;
      // 최장 기록보다 길면 갱신한다.
      if (runningDays > longestDays) {
        // 최장 연속 일수를 갱신한다.
        longestDays = runningDays;
      }
      // 다음 비교를 위해 현재 날짜를 기억한다.
      previousDate = date;
    }
    // 최장 연속 일수를 돌려준다.
    return longestDays;
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the Monday-to-Sunday dates of the week containing a date.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the Monday-to-Sunday dates of the week containing [date].
  static List<DateTime> weekDatesOf(DateTime date) {
    // DateTime.weekday는 월요일=1이므로 그만큼 빼서 월요일을 구한다.
    final mondayDate = _addDays(dateOnly(date), DateTime.monday - date.weekday);
    // 월요일부터 7일을 만든다.
    return List<DateTime>.generate(
      _daysPerWeek,
      // 월요일에서 dayOffset일 뒤의 날짜
      (dayOffset) => _addDays(mondayDate, dayOffset),
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Removes the time-of-day part of a date-time.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns [dateTime] at local midnight.
  static DateTime dateOnly(DateTime dateTime) {
    // 연·월·일만 남긴 새 날짜를 만든다.
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Collects the distinct calendar dates on which practices ended.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Collects the distinct dates on which [sessions] ended.
  static Set<DateTime> collectPracticeDates(List<BowSession> sessions) {
    // 각 기록의 종료 시각에서 날짜만 남겨 집합으로 만든다.
    return sessions.map((session) => dateOnly(session.endedAt)).toSet();
  }

  // 날짜에 일 수를 더한다(서머타임에도 날짜가 밀리지 않도록 일 단위로 계산).
  static DateTime _addDays(DateTime date, int days) {
    // Duration 대신 day 필드에 더해 자정 기준을 유지한다.
    return DateTime(date.year, date.month, date.day + days);
  }
}
