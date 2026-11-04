import 'package:bae108_counter/models/bow_session.dart';
import 'package:bae108_counter/services/practice_statistics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

// 기준일: 2026-11-04 수요일 저녁
final DateTime _today = DateTime(2026, 11, 4, 20);

// 지정한 날짜에 끝난 108배 기록을 만든다.
BowSession _sessionOn(DateTime endedAt) {
  // 40분 전에 시작해 지정 시각에 끝난 기록
  return BowSession(
    id: endedAt.toIso8601String(),
    startedAt: endedAt.subtract(const Duration(minutes: 40)),
    endedAt: endedAt,
    activeDurationSeconds: const Duration(minutes: 38).inSeconds,
    bowCount: 108,
  );
}

void main() {
  group('연속 일수', () {
    test('currentStreakDays_practicedTodayAndPastTwoDays_returnsThree', () {
      // 준비: 테스트 조건을 만든다.
      final dates = PracticeStatisticsCalculator.collectPracticeDates(
        <BowSession>[
          _sessionOn(DateTime(2026, 11, 4, 7)),
          _sessionOn(DateTime(2026, 11, 3, 7)),
          _sessionOn(DateTime(2026, 11, 2, 7)),
          _sessionOn(DateTime(2026, 10, 30, 7)),
        ],
      );

      // 실행: 테스트 대상 동작을 수행한다.
      final streakDays = PracticeStatisticsCalculator.currentStreakDays(
        dates,
        _today,
      );

      // 검증: 기대 결과를 확인한다.
      expect(streakDays, 3);
    });

    test('currentStreakDays_lastPracticeYesterday_keepsStreak', () {
      // 준비: 테스트 조건을 만든다.
      final dates = PracticeStatisticsCalculator.collectPracticeDates(
        <BowSession>[
          _sessionOn(DateTime(2026, 11, 3, 7)),
          _sessionOn(DateTime(2026, 11, 2, 7)),
        ],
      );

      // 실행: 테스트 대상 동작을 수행한다.
      final streakDays = PracticeStatisticsCalculator.currentStreakDays(
        dates,
        _today,
      );

      // 검증: 기대 결과를 확인한다.
      expect(streakDays, 2);
    });

    test('currentStreakDays_lastPracticeTwoDaysAgo_returnsZero', () {
      // 준비: 테스트 조건을 만든다.
      final dates = PracticeStatisticsCalculator.collectPracticeDates(
        <BowSession>[_sessionOn(DateTime(2026, 11, 2, 7))],
      );

      // 실행: 테스트 대상 동작을 수행한다.
      final streakDays = PracticeStatisticsCalculator.currentStreakDays(
        dates,
        _today,
      );

      // 검증: 기대 결과를 확인한다.
      expect(streakDays, 0);
    });

    test('longestStreakDays_acrossMonthBoundary_countsConsecutiveDays', () {
      // 준비: 테스트 조건을 만든다.
      final dates = PracticeStatisticsCalculator.collectPracticeDates(
        <BowSession>[
          _sessionOn(DateTime(2026, 10, 30, 7)),
          _sessionOn(DateTime(2026, 10, 31, 7)),
          _sessionOn(DateTime(2026, 11, 1, 7)),
          _sessionOn(DateTime(2026, 11, 1, 21)),
          _sessionOn(DateTime(2026, 11, 4, 7)),
        ],
      );

      // 실행: 테스트 대상 동작을 수행한다.
      final longestDays = PracticeStatisticsCalculator.longestStreakDays(dates);

      // 검증: 기대 결과를 확인한다.
      expect(longestDays, 3);
    });

    test('longestStreakDays_noRecords_returnsZero', () {
      // 준비 및 실행: 대상을 만들고 동작을 수행한다.
      final longestDays = PracticeStatisticsCalculator.longestStreakDays(
        <DateTime>{},
      );

      // 검증: 기대 결과를 확인한다.
      expect(longestDays, 0);
    });
  });

  group('이번 주와 이번 달', () {
    test('weekDatesOf_wednesday_returnsMondayToSunday', () {
      // 준비 및 실행: 대상을 만들고 동작을 수행한다.
      final weekDates = PracticeStatisticsCalculator.weekDatesOf(_today);

      // 검증: 기대 결과를 확인한다.
      expect(weekDates.first, DateTime(2026, 11, 2));
      expect(weekDates.last, DateTime(2026, 11, 8));
      expect(weekDates, hasLength(7));
    });

    test('calculate_mixedRecords_marksWeekDaysAndSumsMonth', () {
      // 준비: 테스트 조건을 만든다.
      final sessions = <BowSession>[
        _sessionOn(DateTime(2026, 11, 2, 7)),
        _sessionOn(DateTime(2026, 11, 4, 7)),
        _sessionOn(DateTime(2026, 11, 4, 19)),
        _sessionOn(DateTime(2026, 10, 31, 7)),
      ];

      // 실행: 테스트 대상 동작을 수행한다.
      final statistics = PracticeStatisticsCalculator.calculate(
        sessions,
        _today,
      );

      // 검증: 기대 결과를 확인한다.
      expect(statistics.completedWeekDays, <bool>[
        true,
        false,
        true,
        false,
        false,
        false,
        false,
      ]);
      expect(statistics.monthlySessionCount, 3);
      expect(statistics.monthlyBowCount, 108 * 3);
      expect(statistics.currentStreakDays, 1);
    });
  });
}
