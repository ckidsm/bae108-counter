import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows Monday to Sunday of this week with a check on practiced days.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 이번 주 월~일 수행 체크 표시.
class WeekCheckRow extends StatelessWidget {
  /// Creates the week row.
  const WeekCheckRow({
    super.key,
    required this.weekDates,
    required this.completedWeekDays,
    required this.today,
  });

  // 요일 원 지름
  static const double _dayDiameter = 36;
  // 요일 글자와 원 사이 간격
  static const double _labelSpacing = 6;
  // 체크 아이콘 크기
  static const double _checkIconSize = 20;
  // 오늘 표시 테두리 두께
  static const double _todayBorderWidth = 1.5;

  /// The dates from Monday to Sunday.
  final List<DateTime> weekDates;

  /// Whether each date in [weekDates] has a practice.
  final List<bool> completedWeekDays;

  /// Today's date, highlighted with a border.
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    // 현재 언어의 짧은 요일 이름 형식("월", "화"...)
    final weekdayFormat = DateFormat.E(AppLocalizations.of(context).localeName);
    // 7칸을 고르게 배치한다.
    return Row(
      // 고르게 배치
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // 요일마다 칸을 만든다.
        for (var dayIndex = 0; dayIndex < weekDates.length; dayIndex++)
          // 요일 칸
          _buildDay(
            context,
            // 요일 이름
            weekdayFormat.format(weekDates[dayIndex]),
            // 수행 여부
            isCompleted: completedWeekDays[dayIndex],
            // 오늘인지 여부
            isToday: DateUtils.isSameDay(weekDates[dayIndex], today),
          ),
      ],
    );
  }

  // 요일 이름과 체크 원 한 칸
  Widget _buildDay(
    BuildContext context,
    String weekdayLabel, {
    required bool isCompleted,
    required bool isToday,
  }) {
    // 세로로 쌓는다.
    return Column(
      children: <Widget>[
        // 요일 이름
        Text(
          // "월"
          weekdayLabel,
          // 보조 글자
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        // 간격
        const SizedBox(height: _labelSpacing),
        // 원
        Container(
          // 지름
          width: _dayDiameter,
          // 지름
          height: _dayDiameter,
          // 원 꾸밈
          decoration: BoxDecoration(
            // 원 모양
            shape: BoxShape.circle,
            // 수행한 날은 금빛, 아니면 바탕색
            color: isCompleted ? AppColors.gold : AppColors.track,
            // 오늘은 금빛 테두리
            border: isToday
                ? Border.all(color: AppColors.gold, width: _todayBorderWidth)
                : null,
          ),
          // 수행한 날은 체크 표시
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: _checkIconSize,
                  color: AppColors.onGold,
                )
              : null,
        ),
      ],
    );
  }
}
