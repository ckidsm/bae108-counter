import 'package:flutter/material.dart';

import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows four progress bars, one for each 27-bow segment.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 27배 단위 구간 4개의 진행 막대.
class SegmentProgressBars extends StatelessWidget {
  /// Creates the segment bars for [count] bows.
  const SegmentProgressBars({
    super.key,
    required this.count,
    required this.isCompleted,
  });

  // 막대 사이 간격
  static const double _barSpacing = 8;
  // 막대 두께
  static const double _barHeight = 6;
  // 막대와 아래 숫자 사이 간격
  static const double _labelSpacing = 6;

  /// The number of bows counted so far.
  final int count;

  /// Whether the practice is completed.
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 막대를 가로로 나란히 놓는다.
    return Row(
      children: <Widget>[
        // 구간 개수만큼 막대를 만든다.
        for (
          var segmentIndex = 0;
          segmentIndex < CounterRules.segmentCount;
          segmentIndex++
        ) ...<Widget>[
          // 첫 막대가 아니면 간격을 둔다.
          if (segmentIndex > 0) const SizedBox(width: _barSpacing),
          // 막대 하나가 같은 폭을 차지한다.
          Expanded(
            // 막대와 구간 숫자
            child: _SegmentBar(
              // 이 구간의 진행률
              fillRatio: _fillRatioOf(segmentIndex),
              // 완료 여부
              isCompleted: isCompleted,
              // "1–27" 같은 구간 숫자
              label: localizations.segmentRange(
                // 구간 시작 절
                segmentIndex * CounterRules.bowsPerSegment + 1,
                // 구간 끝 절
                (segmentIndex + 1) * CounterRules.bowsPerSegment,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 구간 하나가 얼마나 찼는지 0.0~1.0으로 계산한다.
  double _fillRatioOf(int segmentIndex) {
    // 이 구간 앞까지의 절 수
    final segmentStartCount = segmentIndex * CounterRules.bowsPerSegment;
    // 이 구간 안에서 센 절 수
    final countInSegment = count - segmentStartCount;
    // 구간 길이로 나눠 0~1 범위로 자른다.
    return (countInSegment / CounterRules.bowsPerSegment).clamp(0, 1);
  }
}

// 구간 막대 하나와 그 아래 숫자
class _SegmentBar extends StatelessWidget {
  // 진행률·완료 여부·숫자를 받는다.
  const _SegmentBar({
    required this.fillRatio,
    required this.isCompleted,
    required this.label,
  });

  // 진행률
  final double fillRatio;
  // 완료 여부
  final bool isCompleted;
  // 구간 숫자
  final String label;

  @override
  Widget build(BuildContext context) {
    // 막대와 숫자를 세로로 놓는다.
    return Column(
      children: <Widget>[
        // 둥근 막대
        ClipRRect(
          // 둥근 모서리
          borderRadius: BorderRadius.circular(SegmentProgressBars._barHeight),
          // 진행 막대
          child: LinearProgressIndicator(
            // 진행률
            value: fillRatio,
            // 막대 두께
            minHeight: SegmentProgressBars._barHeight,
            // 바탕색
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            // 완료 시 녹색, 아니면 주황색
            color: isCompleted ? AppColors.completed : AppColors.progress,
          ),
        ),
        // 막대와 숫자 간격
        const SizedBox(height: SegmentProgressBars._labelSpacing),
        // 구간 숫자
        Text(
          // "1–27"
          label,
          // 작은 보조 글자
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: context.textSecondaryColor),
        ),
      ],
    );
  }
}
