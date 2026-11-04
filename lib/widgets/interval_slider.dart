import 'package:flutter/material.dart';

import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the interval value with a 5-second-step slider from 5 seconds to 3 minutes.
 Remarks  : Shared by the custom interval sheet and the settings screen.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 현재 간격 값과 5초~3분(5초 단위) 슬라이더.
class IntervalSlider extends StatelessWidget {
  /// Creates the slider showing [seconds].
  const IntervalSlider({
    super.key,
    required this.seconds,
    required this.onChanged,
  });

  // 현재 값 글자 크기
  static const double _valueFontSize = 40;

  /// The interval shown, in seconds.
  final int seconds;

  /// Called with the new interval while the slider moves.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 시간 문구 형식 도우미
    final formatter = DisplayFormatter(localizations);
    // 5초 단위 칸 수 ((180 - 5) / 5 = 35칸)
    const divisionCount =
        (CounterRules.maximumIntervalSeconds -
            CounterRules.minimumIntervalSeconds) ~/
        CounterRules.intervalStepSeconds;
    // 세로로 쌓는다.
    return Column(
      // 내용 높이만큼만 차지
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // 현재 선택값
        Text(
          // "1분 30초" 같은 값
          formatter.formatDuration(Duration(seconds: seconds)),
          // 큰 버튼색 글자
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            // 글자 크기
            fontSize: _valueFontSize,
            // 버튼색
            color: context.accentColor,
          ),
        ),
        // 5초~3분 슬라이더
        Slider(
          // 현재 값
          value: seconds.toDouble(),
          // 최솟값 5초
          min: CounterRules.minimumIntervalSeconds.toDouble(),
          // 최댓값 180초
          max: CounterRules.maximumIntervalSeconds.toDouble(),
          // 5초 단위 칸
          divisions: divisionCount,
          // 움직이면 5초 단위로 보정한 값을 알린다.
          onChanged: (value) =>
              onChanged(CounterRules.normalizeIntervalSeconds(value.round())),
        ),
        // 허용 범위 안내
        Text(
          // "5초 ~ 3분, 5초 단위"
          localizations.customIntervalRange(
            // 최솟값 문구
            formatter.formatDuration(
              const Duration(seconds: CounterRules.minimumIntervalSeconds),
            ),
            // 최댓값 문구
            formatter.formatDuration(
              const Duration(seconds: CounterRules.maximumIntervalSeconds),
            ),
            // 단위 문구
            formatter.formatDuration(
              const Duration(seconds: CounterRules.intervalStepSeconds),
            ),
          ),
          // 보조 글자
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.textSecondaryColor),
        ),
      ],
    );
  }
}
