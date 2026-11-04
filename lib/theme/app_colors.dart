import 'package:flutter/material.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the dark color palette of the app.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 앱 전체에서 쓰는 다크 테마 색상.
abstract final class AppColors {
  // 화면 배경색(완전한 검정)
  /// The screen background, pure black.
  static const Color background = Color(0xFF000000);

  // 카드 배경색(색조 없는 짙은 회색)
  /// The card surface, a neutral dark gray.
  static const Color card = Color(0xFF161616);

  // 카드보다 한 단계 밝은 면(링 바탕, 비활성 막대)
  /// A neutral surface one step brighter than [card], used for tracks.
  static const Color track = Color(0xFF2C2C2C);

  // 기본 텍스트 색
  /// The primary text color.
  static const Color textPrimary = Color(0xFFF3EDE2);

  // 보조 텍스트 색
  /// The secondary text color.
  static const Color textSecondary = Color(0xFFA89F90);

  // 포인트 금빛
  /// The gold accent color.
  static const Color gold = Color(0xFFD9A441);

  // 진행 중 링 색(주황)
  /// The in-progress ring color.
  static const Color progress = Color(0xFFF08A3C);

  // 완료 링 색(녹색)
  /// The completed ring color.
  static const Color completed = Color(0xFF5FB878);

  // 금빛 위에 올리는 글자 색
  /// The text color placed on [gold].
  static const Color onGold = Color(0xFF000000);
}
