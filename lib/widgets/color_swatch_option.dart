import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows one selectable color circle with its name below.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 이름이 붙은 선택형 색 견본 원.
class ColorSwatchOption extends StatelessWidget {
  /// Creates a color option.
  const ColorSwatchOption({
    super.key,
    required this.label,
    required this.fillColor,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
    this.innerColor,
  });

  // 견본 원 지름
  static const double _diameter = 44;
  // 안쪽 원 지름
  static const double _innerDiameter = 18;
  // 견본 칸 폭(이름 포함)
  static const double _optionWidth = 74;
  // 테두리 두께
  static const double _borderWidth = 1;
  // 선택 테두리 두께
  static const double _selectedBorderWidth = 3;
  // 원과 이름 사이 간격
  static const double _labelSpacing = 6;
  // 선택 체크 아이콘 크기
  static const double _checkIconSize = 20;
  // 눌림 효과 모서리 반지름
  static const double _inkRadius = 12;

  /// The color name shown below the circle.
  final String label;

  /// The circle color.
  final Color fillColor;

  /// The thin border color used when not selected.
  final Color borderColor;

  /// An optional smaller circle drawn inside, such as the card color.
  final Color? innerColor;

  /// Whether this option is the current choice.
  final bool isSelected;

  /// Called when the option is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 눌림 효과가 있는 칸
    return InkWell(
      // 누르면 선택
      onTap: onTap,
      // 둥근 눌림 효과
      borderRadius: BorderRadius.circular(_inkRadius),
      // 고정 폭 칸
      child: SizedBox(
        // 칸 폭
        width: _optionWidth,
        // 원과 이름을 세로로 쌓는다.
        child: Column(
          children: <Widget>[
            // 색 원
            Container(
              // 지름
              width: _diameter,
              // 지름
              height: _diameter,
              // 원 꾸밈
              decoration: BoxDecoration(
                // 원 모양
                shape: BoxShape.circle,
                // 견본 색
                color: fillColor,
                // 선택 시 버튼색 굵은 테두리, 아니면 얇은 테두리
                border: Border.all(
                  color: isSelected ? context.accentColor : borderColor,
                  width: isSelected ? _selectedBorderWidth : _borderWidth,
                ),
              ),
              // 안쪽 원 또는 선택 체크
              child: Center(child: _buildCenter()),
            ),
            // 간격
            const SizedBox(height: _labelSpacing),
            // 색 이름(칸보다 길면 글자를 줄여 한 줄에 맞춘다)
            FittedBox(
              // 줄이기만 한다.
              fit: BoxFit.scaleDown,
              // 이름 글자
              child: Text(
                // 이름
                label,
                // 한 줄
                maxLines: 1,
                // 작은 글자(선택 시 버튼색)
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? context.accentColor
                      : context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 원 가운데: 안쪽 색 원이 있으면 그 원, 없으면 선택 시 체크
  Widget? _buildCenter() {
    // 안쪽 색(카드색)
    final centerColor = innerColor;
    // 안쪽 색이 있으면 작은 원을 그린다.
    if (centerColor != null) {
      // 작은 원
      return Container(
        // 지름
        width: _innerDiameter,
        // 지름
        height: _innerDiameter,
        // 원 모양 안쪽 색
        decoration: BoxDecoration(shape: BoxShape.circle, color: centerColor),
      );
    }
    // 버튼색 견본은 선택 시 흰 체크를 보여 준다.
    return isSelected
        ? const Icon(Icons.check, size: _checkIconSize, color: Colors.white)
        : null;
  }
}
