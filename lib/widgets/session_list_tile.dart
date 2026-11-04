import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bow_session.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows one practice record with its date, time range, memo, and duration.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 최근 수행 목록의 한 줄.
class SessionListTile extends StatelessWidget {
  /// Creates the tile for [session].
  const SessionListTile({super.key, required this.session});

  // 카드 안쪽 여백
  static const double _cardPadding = 16;
  // 줄 사이 간격
  static const double _lineSpacing = 4;

  /// The record to show.
  final BowSession session;

  @override
  Widget build(BuildContext context) {
    // 시간 문구 형식 도우미
    final formatter = DisplayFormatter(AppLocalizations.of(context));
    // 글자 스타일
    final textTheme = Theme.of(context).textTheme;
    // 카드
    return Card(
      // 안쪽 여백
      child: Padding(
        // 여백
        padding: const EdgeInsets.all(_cardPadding),
        // 왼쪽 정보와 오른쪽 소요 시간
        child: Row(
          children: <Widget>[
            // 왼쪽 정보가 남은 폭을 차지한다.
            Expanded(
              // 세로로 쌓는다.
              child: Column(
                // 왼쪽 정렬
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 날짜
                  Text(
                    // "2026.11.04 (수)"
                    formatter.formatDate(session.endedAt),
                    // 굵은 글자
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // 간격
                  const SizedBox(height: _lineSpacing),
                  // 시작→종료 시각
                  Text(
                    // "14:02 → 14:40"
                    formatter.formatTimeRange(
                      session.startedAt,
                      session.endedAt,
                    ),
                    // 보조 글자
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // 메모가 있으면 보여 준다.
                  if (session.memo.isNotEmpty) ...<Widget>[
                    // 간격
                    const SizedBox(height: _lineSpacing),
                    // 메모
                    Text(
                      // 메모 내용
                      session.memo,
                      // 길면 말줄임
                      overflow: TextOverflow.ellipsis,
                      // 기본 글자
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            // 소요 시간
            Text(
              // "38분 12초"
              formatter.formatDuration(session.activeDuration),
              // 금빛 글자
              style: textTheme.titleSmall?.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
