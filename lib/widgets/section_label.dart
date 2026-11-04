import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows a small caption above a group of controls.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 설정 묶음 위에 붙는 작은 제목.
class SectionLabel extends StatelessWidget {
  /// Creates a caption with [text].
  const SectionLabel(this.text, {super.key});

  // 제목과 아래 컨트롤 사이 간격
  static const double _bottomSpacing = 8;

  /// The caption text.
  final String text;

  @override
  Widget build(BuildContext context) {
    // 아래쪽에만 여백을 둔다.
    return Padding(
      // 아래 간격
      padding: const EdgeInsets.only(bottom: _bottomSpacing),
      // 보조 색의 작은 글자
      child: Text(
        // 제목 문구
        text,
        // 작은 보조 글자
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
