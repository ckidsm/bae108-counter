import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/counter_phase.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the start/pause and restart buttons below the counter.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 하단의 [시작/일시정지] [처음부터] 버튼 줄.
class CounterControls extends StatelessWidget {
  /// Creates the control row.
  const CounterControls({
    super.key,
    required this.phase,
    required this.count,
    required this.onPrimaryPressed,
    required this.onReset,
  });

  // 버튼 사이 간격
  static const double _buttonSpacing = 12;
  // 버튼 높이
  static const double _buttonHeight = 56;

  /// The current lifecycle phase.
  final CounterPhase phase;

  /// The number of bows counted so far.
  final int count;

  /// Called when the start button is pressed.
  final VoidCallback onPrimaryPressed;

  /// Called when "처음부터" is pressed.
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 진행 중인지 여부(일시정지 버튼으로 표시)
    final isActive =
        phase == CounterPhase.preparing || phase == CounterPhase.running;
    // 두 버튼을 가로로 놓는다.
    return SizedBox(
      // 버튼 높이
      height: _buttonHeight,
      // 가로 배치
      child: Row(
        // 버튼 높이를 맞춘다.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 시작 버튼이 남은 폭을 차지한다.
          Expanded(
            // 시작/이어서/일시정지/회향하기 버튼
            child: FilledButton.icon(
              // 누르면 상위에서 처리
              onPressed: onPrimaryPressed,
              // 상태에 맞는 아이콘
              icon: Icon(_primaryIconOf(isActive)),
              // 상태에 맞는 이름
              label: Text(_primaryLabelOf(localizations, isActive)),
            ),
          ),
          // 간격
          const SizedBox(width: _buttonSpacing),
          // 처음부터 버튼
          OutlinedButton.icon(
            // 대기 상태에서 0배면 비활성
            onPressed: phase == CounterPhase.idle && count == 0
                ? null
                : onReset,
            // 다시 시작 아이콘
            icon: const Icon(Icons.restart_alt),
            // "처음부터"
            label: Text(localizations.buttonReset),
          ),
        ],
      ),
    );
  }

  // 시작 버튼 아이콘을 고른다.
  IconData _primaryIconOf(bool isActive) {
    // 완료면 연꽃 아이콘
    if (phase == CounterPhase.completed) {
      // 연꽃(spa) 아이콘
      return Icons.spa_outlined;
    }
    // 진행 중이면 일시정지, 아니면 재생 아이콘
    return isActive ? Icons.pause : Icons.play_arrow;
  }

  // 시작 버튼 이름을 고른다.
  String _primaryLabelOf(AppLocalizations localizations, bool isActive) {
    // 단계별로 이름이 다르다.
    return switch (phase) {
      // 완료: 회향하기
      CounterPhase.completed => localizations.buttonDedication,
      // 일시정지: 이어서
      CounterPhase.paused => localizations.buttonResume,
      // 대기: 이미 센 절이 있으면 이어서, 아니면 시작
      CounterPhase.idle =>
        count > 0 ? localizations.buttonResume : localizations.buttonStart,
      // 준비·진행 중: 일시정지
      CounterPhase.preparing ||
      CounterPhase.running => localizations.buttonPause,
    };
  }
}
