/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds the aggregated practice statistics shown on the history screen.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 기록 화면에 표시할 집계 결과.
class PracticeStatistics {
  /// Creates an aggregated statistics snapshot.
  const PracticeStatistics({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weekDates,
    required this.completedWeekDays,
    required this.monthlySessionCount,
    required this.monthlyBowCount,
  });

  /// The number of consecutive days ending today or yesterday.
  final int currentStreakDays;

  /// The longest run of consecutive practice days.
  final int longestStreakDays;

  /// The dates from Monday to Sunday of the current week.
  final List<DateTime> weekDates;

  /// Whether a practice exists on each date in [weekDates].
  final List<bool> completedWeekDays;

  /// The number of practices in the current month.
  final int monthlySessionCount;

  /// The number of bows completed in the current month.
  final int monthlyBowCount;
}
