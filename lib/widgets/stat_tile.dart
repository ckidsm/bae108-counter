import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows one labeled statistic value inside a card.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 이름과 값을 위아래로 보여 주는 통계 칸.
class StatTile extends StatelessWidget {
  /// Creates a statistic tile.
  const StatTile({super.key, required this.label, required this.value});

  // 이름과 값 사이 간격
  static const double _labelSpacing = 4;

  /// The statistic name.
  final String label;

  /// The formatted statistic value.
  final String value;

  @override
  Widget build(BuildContext context) {
    // 글자 스타일
    final textTheme = Theme.of(context).textTheme;
    // 세로로 쌓는다.
    return Column(
      children: <Widget>[
        // 값(칸보다 길면 글자를 줄여 한 줄에 맞춘다)
        FittedBox(
          // 줄이기만 하고 키우지는 않는다.
          fit: BoxFit.scaleDown,
          // 값 글자
          child: Text(
            // 값 문구
            value,
            // 굵은 큰 글자
            style: textTheme.titleLarge?.copyWith(
              // 굵게
              fontWeight: FontWeight.w700,
              // 기본 글자색
              color: context.textPrimaryColor,
            ),
          ),
        ),
        // 간격
        const SizedBox(height: _labelSpacing),
        // 이름
        Text(
          // 이름 문구
          label,
          // 가운데 정렬
          textAlign: TextAlign.center,
          // 보조 글자
          style: textTheme.bodySmall?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
