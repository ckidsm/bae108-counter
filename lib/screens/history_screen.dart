import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bow_session.dart';
import '../models/practice_statistics.dart';
import '../services/practice_record_repository.dart';
import '../services/practice_statistics_calculator.dart';
import '../theme/app_colors.dart';
import '../widgets/session_list_tile.dart';
import '../widgets/stat_tile.dart';
import '../widgets/week_check_row.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows streaks, this week's check marks, monthly totals, and recent records.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// "수행 기록" 화면.
class HistoryScreen extends StatelessWidget {
  /// Creates the history screen reading from [repository].
  const HistoryScreen({super.key, required this.repository});

  // 화면 여백
  static const double _screenPadding = 20;
  // 카드 안쪽 여백
  static const double _cardPadding = 20;
  // 카드 사이 간격
  static const double _cardSpacing = 12;
  // 제목 아래 간격
  static const double _titleSpacing = 16;
  // 빈 목록 안내 위쪽 여백
  static const double _emptyMessageTopPadding = 32;

  /// Provides the stored practice records.
  final PracticeRecordRepository repository;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 오늘 날짜
    final today = DateTime.now();
    // 저장된 기록(최근순)
    final sessions = repository.loadSessions();
    // 통계 계산
    final statistics = PracticeStatisticsCalculator.calculate(sessions, today);
    // 화면 뼈대
    return Scaffold(
      // 상단 바
      appBar: AppBar(title: Text(localizations.historyTitle)),
      // 스크롤 목록
      body: ListView(
        // 여백
        padding: const EdgeInsets.all(_screenPadding),
        children: <Widget>[
          // 연속 수행 카드
          _buildStreakCard(context, localizations, statistics),
          // 간격
          const SizedBox(height: _cardSpacing),
          // 이번 주 카드
          _buildCard(
            context,
            // "이번 주"
            title: localizations.thisWeekTitle,
            // 월~일 체크
            child: WeekCheckRow(
              // 이번 주 날짜
              weekDates: statistics.weekDates,
              // 수행 여부
              completedWeekDays: statistics.completedWeekDays,
              // 오늘
              today: today,
            ),
          ),
          // 간격
          const SizedBox(height: _cardSpacing),
          // 이번 달 카드
          _buildMonthCard(context, localizations, statistics),
          // 간격
          const SizedBox(height: _titleSpacing * 2),
          // "최근 수행"
          Text(
            // 제목
            localizations.recentSessionsTitle,
            // 제목 글자
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // 간격
          const SizedBox(height: _cardSpacing),
          // 최근 기록 목록
          ..._buildSessionList(context, localizations, sessions),
        ],
      ),
    );
  }

  // 현재·최장 연속 일수 카드
  Widget _buildStreakCard(
    BuildContext context,
    AppLocalizations localizations,
    PracticeStatistics statistics,
  ) {
    // 제목이 있는 카드
    return _buildCard(
      context,
      // "연속 수행"
      title: localizations.streakTitle,
      // 두 칸
      child: Row(
        // 고르게 배치
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // 현재 연속
          StatTile(
            // "현재"
            label: localizations.currentStreakLabel,
            // "N일"
            value: localizations.streakDaysValue(statistics.currentStreakDays),
          ),
          // 최장 연속
          StatTile(
            // "최장"
            label: localizations.longestStreakLabel,
            // "N일"
            value: localizations.streakDaysValue(statistics.longestStreakDays),
          ),
        ],
      ),
    );
  }

  // 이번 달 횟수·누적 절 수 카드
  Widget _buildMonthCard(
    BuildContext context,
    AppLocalizations localizations,
    PracticeStatistics statistics,
  ) {
    // 제목이 있는 카드
    return _buildCard(
      context,
      // "이번 달"
      title: localizations.thisMonthTitle,
      // 두 칸
      child: Row(
        // 고르게 배치
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // 수행 횟수
          StatTile(
            // "수행 횟수"
            label: localizations.monthlySessionLabel,
            // "N회"
            value: localizations.monthlySessionValue(
              statistics.monthlySessionCount,
            ),
          ),
          // 누적 절 수
          StatTile(
            // "누적 절 수"
            label: localizations.monthlyBowLabel,
            // "N절"
            value: localizations.monthlyBowValue(statistics.monthlyBowCount),
          ),
        ],
      ),
    );
  }

  // 최근 기록 목록(없으면 안내 문구)
  List<Widget> _buildSessionList(
    BuildContext context,
    AppLocalizations localizations,
    List<BowSession> sessions,
  ) {
    // 기록이 없으면 안내 문구 하나만 돌려준다.
    if (sessions.isEmpty) {
      // 안내 문구
      return <Widget>[
        // 위쪽 여백
        Padding(
          // 여백
          padding: const EdgeInsets.only(top: _emptyMessageTopPadding),
          // 가운데 안내
          child: Center(
            // "아직 저장된 기록이 없습니다"
            child: Text(
              // 문구
              localizations.emptyHistory,
              // 보조 글자
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ];
    }
    // 기록마다 한 줄씩 만든다.
    return <Widget>[
      // 각 기록
      for (final session in sessions)
        // 아래 간격을 둔 기록 줄
        Padding(
          // 아래 간격
          padding: const EdgeInsets.only(bottom: _cardSpacing),
          // 기록 줄
          child: SessionListTile(session: session),
        ),
    ];
  }

  // 제목과 내용을 가진 카드
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    // 카드
    return Card(
      // 안쪽 여백
      child: Padding(
        // 여백
        padding: const EdgeInsets.all(_cardPadding),
        // 세로로 쌓는다.
        child: Column(
          // 왼쪽 정렬
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 카드 제목
            Text(
              // 제목 문구
              title,
              // 보조 글자
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.textSecondary),
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
