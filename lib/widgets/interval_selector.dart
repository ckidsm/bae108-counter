import 'package:flutter/material.dart';

import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import 'custom_interval_sheet.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the 5/10/20-second preset chips and the custom interval chip.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 5초·10초·20초 프리셋 칩과 직접 설정 칩.
class IntervalSelector extends StatelessWidget {
  /// Creates the interval chips.
  const IntervalSelector({
    super.key,
    required this.intervalSeconds,
    required this.onChanged,
  });

  // 칩 사이 간격
  static const double _chipSpacing = 8;

  /// The current interval, in seconds.
  final int intervalSeconds;

  /// Called with the newly selected interval, in seconds.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 시간 문구 형식 도우미
    final formatter = DisplayFormatter(localizations);
    // 현재 간격이 프리셋 중 하나가 아니면 직접 설정 값이다.
    final isCustomSelected = !CounterRules.presetIntervalSeconds.contains(
      intervalSeconds,
    );
    // 칩을 가로로 늘어놓고 넘치면 줄을 바꾼다.
    return Wrap(
      // 가로 간격
      spacing: _chipSpacing,
      // 세로 간격
      runSpacing: _chipSpacing,
      children: <Widget>[
        // 프리셋 칩
        for (final presetSeconds in CounterRules.presetIntervalSeconds)
          // 선택형 칩
          ChoiceChip(
            // "5초" 같은 이름
            label: Text(localizations.durationSeconds(presetSeconds)),
            // 현재 값과 같으면 선택 상태
            selected: intervalSeconds == presetSeconds,
            // 누르면 해당 간격으로 바꾼다.
            onSelected: (_) => onChanged(presetSeconds),
          ),
        // 직접 설정 칩
        ChoiceChip(
          // 선택되어 있으면 값까지 보여 준다.
          label: Text(
            isCustomSelected
                ? localizations.intervalCustomSelected(
                    formatter.formatDuration(
                      Duration(seconds: intervalSeconds),
                    ),
                  )
                : localizations.intervalCustom,
          ),
          // 직접 설정 값이면 선택 상태
          selected: isCustomSelected,
          // 누르면 슬라이더 시트를 연다.
          onSelected: (_) => _openCustomSheet(context),
        ),
      ],
    );
  }

  // 직접 설정 시트를 열고, 적용한 값이 있으면 알린다.
  Future<void> _openCustomSheet(BuildContext context) async {
    // 시트를 열어 사용자가 고른 초를 받는다.
    final selectedSeconds = await showModalBottomSheet<int>(
      // 현재 화면 문맥
      context: context,
      // 시트 상단 손잡이 표시
      showDragHandle: true,
      // 시트 내용
      builder: (_) => CustomIntervalSheet(initialSeconds: intervalSeconds),
    );
    // 취소했으면 아무것도 하지 않는다.
    if (selectedSeconds == null) {
      // 변경 없음
      return;
    }
    // 고른 간격을 알린다.
    onChanged(selectedSeconds);
  }
}
