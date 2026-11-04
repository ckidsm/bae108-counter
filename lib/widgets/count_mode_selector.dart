import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/count_mode.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Lets the user choose between tap counting and automatic intervals.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// "직접 탭" / "자동 간격" 선택 세그먼트.
class CountModeSelector extends StatelessWidget {
  /// Creates the selector. Pass a null [onChanged] to disable it.
  const CountModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  /// The currently selected mode.
  final CountMode selectedMode;

  /// Called with the newly selected mode, or null when disabled.
  final ValueChanged<CountMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 가로 전체를 채우는 세그먼트 버튼
    return SizedBox(
      // 가로 전체
      width: double.infinity,
      // 두 개 중 하나를 고르는 세그먼트
      child: SegmentedButton<CountMode>(
        // 선택 표시 아이콘은 숨긴다.
        showSelectedIcon: false,
        // 현재 선택값
        selected: <CountMode>{selectedMode},
        // 선택이 바뀌면 첫 번째 값을 알린다(비활성이면 null).
        onSelectionChanged: onChanged == null
            ? null
            : (selection) => onChanged!(selection.first),
        // 선택지 목록
        segments: <ButtonSegment<CountMode>>[
          // 직접 탭
          ButtonSegment<CountMode>(
            // 값
            value: CountMode.tap,
            // 손가락 아이콘
            icon: const Icon(Icons.touch_app_outlined),
            // "직접 탭"
            label: Text(localizations.countModeTap),
          ),
          // 자동 간격
          ButtonSegment<CountMode>(
            // 값
            value: CountMode.auto,
            // 타이머 아이콘
            icon: const Icon(Icons.timer_outlined),
            // "자동 간격"
            label: Text(localizations.countModeAuto),
          ),
        ],
      ),
    );
  }
}
