import 'package:flutter/material.dart';

import '../controllers/counter_controller.dart';
import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/counter_phase.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the guide sentence for the current phase, such as the time to the next bow.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 현재 단계에 맞는 안내 문구("다음 절까지 N초" 등).
class GuideMessage extends StatelessWidget {
  /// Creates the guide sentence for [controller].
  const GuideMessage({super.key, required this.controller});

  /// The counter whose state is described.
  final CounterController controller;

  @override
  Widget build(BuildContext context) {
    // 단계에 맞는 문구를 가운데에 보여 준다.
    return Text(
      // 안내 문구
      messageOf(AppLocalizations.of(context), controller),
      // 가운데 정렬
      textAlign: TextAlign.center,
      // 완료 시 녹색, 아니면 버튼색
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        // 글자색
        color: controller.isCompleted
            ? AppColors.completed
            : context.accentColor,
      ),
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Selects the localized guide sentence for the controller state.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the guide sentence describing [controller].
  static String messageOf(
    AppLocalizations localizations,
    CounterController controller,
  ) {
    // 단계별로 문구를 고른다.
    return switch (controller.phase) {
      // 대기: 준비 시간과 간격 안내
      CounterPhase.idle => localizations.guideIdle(
        CounterRules.preparationSeconds,
        DisplayFormatter(localizations)
            .formatDuration(Duration(seconds: controller.intervalSeconds)),
      ),
      // 준비: 남은 준비 시간
      CounterPhase.preparing => localizations.guidePreparing(
        controller.preparationRemainingSeconds,
      ),
      // 진행: 108배째 절이면 완료까지, 아니면 다음 절까지 남은 시간
      CounterPhase.running =>
        controller.count >= CounterRules.targetBowCount
            ? localizations.guideFinalBow(controller.nextBowRemainingSeconds)
            : localizations.guideRunning(controller.nextBowRemainingSeconds),
      // 정지 안내
      CounterPhase.paused => localizations.guidePaused,
      // 완료 안내
      CounterPhase.completed => localizations.guideCompleted,
    };
  }
}
