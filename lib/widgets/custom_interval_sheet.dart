import 'package:flutter/material.dart';

import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Lets the user pick an interval from 5 seconds to 3 minutes in 5-second steps.
 Remarks  : Pops the chosen seconds when applied, or nothing when dismissed.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 5초~3분, 5초 단위 슬라이더로 간격을 고르는 하단 시트.
class CustomIntervalSheet extends StatefulWidget {
  /// Creates the sheet starting at [initialSeconds].
  const CustomIntervalSheet({super.key, required this.initialSeconds});

  /// The interval shown when the sheet opens, in seconds.
  final int initialSeconds;

  @override
  State<CustomIntervalSheet> createState() => _CustomIntervalSheetState();
}

// 슬라이더 값 상태
class _CustomIntervalSheetState extends State<CustomIntervalSheet> {
  // 시트 안쪽 여백
  static const double _horizontalPadding = 24;
  // 시트 아래 여백
  static const double _bottomPadding = 24;
  // 항목 사이 간격
  static const double _itemSpacing = 12;
  // 현재 값 글자 크기
  static const double _valueFontSize = 40;

  // 슬라이더가 가리키는 초
  late int _selectedSeconds = CounterRules.normalizeIntervalSeconds(
    widget.initialSeconds,
  );

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
    // 시트 내용
    return SafeArea(
      // 여백
      child: Padding(
        // 좌우·아래 여백
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          0,
          _horizontalPadding,
          _bottomPadding,
        ),
        // 세로로 쌓는다.
        child: Column(
          // 내용 높이만큼만 차지
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 시트 제목
            Text(
              // "절 간격 직접 설정"
              localizations.customIntervalSheetTitle,
              // 제목 글자
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // 간격
            const SizedBox(height: _itemSpacing),
            // 현재 선택값
            Text(
              // "1분 30초" 같은 값
              formatter.formatDuration(Duration(seconds: _selectedSeconds)),
              // 큰 금빛 글자
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                // 글자 크기
                fontSize: _valueFontSize,
                // 금빛
                color: AppColors.gold,
              ),
            ),
            // 5초~3분 슬라이더
            Slider(
              // 현재 값
              value: _selectedSeconds.toDouble(),
              // 최솟값 5초
              min: CounterRules.minimumIntervalSeconds.toDouble(),
              // 최댓값 180초
              max: CounterRules.maximumIntervalSeconds.toDouble(),
              // 5초 단위 칸
              divisions: divisionCount,
              // 움직이면 값을 갱신한다.
              onChanged: (value) => setState(
                // 5초 단위로 보정해 저장한다.
                () => _selectedSeconds = CounterRules.normalizeIntervalSeconds(
                  value.round(),
                ),
              ),
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
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            // 간격
            const SizedBox(height: _itemSpacing),
            // 적용 버튼
            SizedBox(
              // 가로 전체
              width: double.infinity,
              // 채워진 버튼
              child: FilledButton(
                // 선택값을 돌려주며 시트를 닫는다.
                onPressed: () => Navigator.of(context).pop(_selectedSeconds),
                // "적용"
                child: Text(localizations.customIntervalApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
