import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/alert_mode.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Lets the user choose bell, vibration, or silent feedback.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// "종소리" / "진동" / "무음" 선택 세그먼트.
class AlertModeSelector extends StatelessWidget {
  /// Creates the selector.
  const AlertModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  /// The currently selected feedback.
  final AlertMode selectedMode;

  /// Called with the newly selected feedback.
  final ValueChanged<AlertMode> onChanged;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 가로 전체를 채우는 세그먼트 버튼
    return SizedBox(
      // 가로 전체
      width: double.infinity,
      // 세 개 중 하나를 고르는 세그먼트
      child: SegmentedButton<AlertMode>(
        // 선택 표시 아이콘은 숨긴다.
        showSelectedIcon: false,
        // 현재 선택값
        selected: <AlertMode>{selectedMode},
        // 선택이 바뀌면 첫 번째 값을 알린다.
        onSelectionChanged: (selection) => onChanged(selection.first),
        // 선택지 목록
        segments: <ButtonSegment<AlertMode>>[
          // 종소리
          ButtonSegment<AlertMode>(
            // 값
            value: AlertMode.bell,
            // 종 아이콘
            icon: const Icon(Icons.notifications_active_outlined),
            // "종소리"
            label: Text(localizations.alertModeBell),
          ),
          // 진동
          ButtonSegment<AlertMode>(
            // 값
            value: AlertMode.vibration,
            // 진동 아이콘
            icon: const Icon(Icons.vibration),
            // "진동"
            label: Text(localizations.alertModeVibration),
          ),
          // 무음
          ButtonSegment<AlertMode>(
            // 값
            value: AlertMode.silent,
            // 음소거 아이콘
            icon: const Icon(Icons.volume_off_outlined),
            // "무음"
            label: Text(localizations.alertModeSilent),
          ),
        ],
      ),
    );
  }
}
