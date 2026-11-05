import 'package:flutter/material.dart';

import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows today's start time, elapsed time, and remaining bows on the tablet layout.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 태블릿 오른쪽 열의 "오늘" 진행 카드(시작 시각·경과·남은 절).
class TodayProgressCard extends StatelessWidget {
  /// Creates the card.
  const TodayProgressCard({
    super.key,
    required this.startedAt,
    required this.activeElapsed,
    required this.count,
  });

  // 카드 안쪽 여백
  static const double _cardPadding = 16;
  // 줄 사이 간격
  static const double _rowSpacing = 8;
  // 아직 시작하지 않았을 때 표시
  static const String _emptyValue = '—';

  /// The time bow 1 started, or null before the start.
  final DateTime? startedAt;

  /// The practice time excluding stops and the countdown.
  final Duration activeElapsed;

  /// The bow currently being performed.
  final int count;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 시간 문구 형식 도우미
    final formatter = DisplayFormatter(localizations);
    // 시작 시각(아직이면 대시)
    final started = startedAt;
    // 카드
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // "오늘"
            Text(
              localizations.todayTitle,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: context.textSecondaryColor),
            ),
            // 간격
            const SizedBox(height: _rowSpacing),
            // 시작 시각
            _buildRow(
              context,
              localizations.todayStartedLabel,
              started == null ? _emptyValue : formatter.formatTime(started),
            ),
            // 경과 시간
            _buildRow(
              context,
              localizations.todayElapsedLabel,
              formatter.formatDuration(activeElapsed),
            ),
            // 남은 절(지금 하는 절은 남은 것으로 보지 않는다)
            _buildRow(
              context,
              localizations.todayRemainingLabel,
              localizations.remainingBowsValue(
                (CounterRules.targetBowCount - count).clamp(
                  0,
                  CounterRules.targetBowCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이름과 값을 양 끝에 놓은 한 줄
  Widget _buildRow(BuildContext context, String label, String value) {
    // 글자 스타일
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    // 위아래 여백
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _rowSpacing / 2),
      // 양 끝 정렬
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 이름(보조 색)
          Text(
            label,
            style: textStyle?.copyWith(color: context.textSecondaryColor),
          ),
          // 값(굵게)
          Text(value, style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
