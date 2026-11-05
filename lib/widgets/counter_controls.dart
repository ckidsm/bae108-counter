import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/counter_phase.dart';
import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the start, stop, and restart buttons below the counter.
 Remarks  : After completion the start button opens the dedication screen instead.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
 History  : [2026-11-05, YUNDEOKSOO] Split start/pause toggle into start and stop buttons
────────────────────────────────────────────────────────────────────────*/
/// 하단의 [시작] [정지] [처음부터] 버튼 줄.
class CounterControls extends StatelessWidget {
  /// Creates the control row.
  const CounterControls({
    super.key,
    required this.phase,
    required this.count,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    this.isVertical = false,
  });

  // 버튼 사이 간격
  static const double _buttonSpacing = 10;
  // 버튼 높이
  static const double _buttonHeight = 56;
  // 태블릿 세로 배치 버튼 높이
  static const double _tabletButtonHeight = 64;

  /// The current lifecycle phase.
  final CounterPhase phase;

  /// The number of bows counted so far.
  final int count;

  /// Called when the start button is pressed (also used for "회향하기").
  final VoidCallback onStart;

  /// Called when the stop button is pressed.
  final VoidCallback onStop;

  /// Called when "처음부터" is pressed.
  final VoidCallback onReset;

  /// Whether to stack the buttons vertically (tablet layout).
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 준비·진행 중인지 여부
    final isActive =
        phase == CounterPhase.preparing || phase == CounterPhase.running;
    // 완료 여부
    final isCompleted = phase == CounterPhase.completed;
    // 시작 버튼(진행 중에는 비활성, 완료 후에는 회향하기)
    final startButton = FilledButton.icon(
      // 진행 중에는 누를 수 없다.
      onPressed: isActive ? null : onStart,
      // 완료면 연꽃, 아니면 재생 아이콘
      icon: Icon(isCompleted ? Icons.spa_outlined : Icons.play_arrow),
      // 완료면 "회향하기", 아니면 "시작"
      label: Text(
        isCompleted
            ? localizations.buttonDedication
            : localizations.buttonStart,
      ),
    );
    // 정지 버튼(진행 중에만 누를 수 있다)
    final stopButton = FilledButton.icon(
      // 진행 중일 때만 누를 수 있다.
      onPressed: isActive ? onStop : null,
      // 눈에 띄도록 빨간 바탕과 흰 글자
      style: FilledButton.styleFrom(
        // 정지 버튼 배경
        backgroundColor: AppColors.stop,
        // 정지 버튼 글자
        foregroundColor: AppColors.onStop,
      ),
      // 정지 아이콘
      icon: const Icon(Icons.stop),
      // "정지"
      label: Text(localizations.buttonStop),
    );
    // 처음부터 버튼
    final resetButton = OutlinedButton.icon(
      // 대기 상태에서 0배면 비활성
      onPressed: phase == CounterPhase.idle && count == 0 ? null : onReset,
      // 다시 시작 아이콘
      icon: const Icon(Icons.restart_alt),
      // "처음부터"
      label: Text(localizations.buttonReset),
    );
    // 태블릿은 세 버튼을 세로로 쌓는다.
    if (isVertical) {
      // 세로 배치
      return Column(
        // 버튼 폭을 열 폭에 맞춘다.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 시작
          SizedBox(height: _tabletButtonHeight, child: startButton),
          // 간격
          const SizedBox(height: _buttonSpacing),
          // 정지
          SizedBox(height: _tabletButtonHeight, child: stopButton),
          // 간격
          const SizedBox(height: _buttonSpacing),
          // 처음부터
          SizedBox(height: _tabletButtonHeight, child: resetButton),
        ],
      );
    }
    // 휴대폰은 세 버튼을 가로로 놓는다.
    return SizedBox(
      // 버튼 높이
      height: _buttonHeight,
      // 가로 배치
      child: Row(
        // 버튼 높이를 맞춘다.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 시작
          Expanded(child: startButton),
          // 간격
          const SizedBox(width: _buttonSpacing),
          // 정지
          Expanded(child: stopButton),
          // 간격
          const SizedBox(width: _buttonSpacing),
          // 처음부터
          resetButton,
        ],
      ),
    );
  }
}
