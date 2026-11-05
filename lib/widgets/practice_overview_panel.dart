import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/practice_statistics.dart';
import '../theme/app_colors.dart';
import 'week_check_row.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the current streak and this week's check marks on the tablet layout.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 태블릿 왼쪽 열의 연속 수행·이번 주 카드.
class PracticeOverviewPanel extends StatelessWidget {
  /// Creates the panel for [statistics] relative to [today].
  const PracticeOverviewPanel({
    super.key,
    required this.statistics,
    required this.today,
  });

  // 카드 사이 간격
  static const double _cardSpacing = 12;
  // 카드 안쪽 여백
  static const double _cardPadding = 16;
  // 카드 제목과 내용 사이 간격
  static const double _titleSpacing = 10;

  /// The practice statistics to show.
  final PracticeStatistics statistics;

  /// Today's date, highlighted in the week row.
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 세로로 쌓는다.
    return Column(
      // 왼쪽 정렬
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 연속 수행 카드
        _buildCard(
          context,
          // "연속 수행"
          title: localizations.streakTitle,
          // "3일"
          child: Text(
            localizations.streakDaysValue(statistics.currentStreakDays),
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // 간격
        const SizedBox(height: _cardSpacing),
        // 이번 주 카드
        _buildCard(
          context,
          // "이번 주"
          title: localizations.thisWeekTitle,
          // 월~일 체크
          child: WeekCheckRow(
            weekDates: statistics.weekDates,
            completedWeekDays: statistics.completedWeekDays,
            today: today,
          ),
        ),
      ],
    );
  }

  // 제목이 있는 카드
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    // 카드
    return Card(
      // 안쪽 여백
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        // 제목과 내용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 카드 제목(보조 글자)
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: context.textSecondaryColor),
            ),
            // 간격
            const SizedBox(height: _titleSpacing),
            // 내용
            child,
          ],
        ),
      ),
    );
  }
}
