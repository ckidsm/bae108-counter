import 'package:flutter/material.dart';

import '../models/accent_preset.dart';
import '../models/background_preset.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the ring status colors that stay the same in every theme.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 테마와 관계없이 고정인 진행 상태 색.
abstract final class AppColors {
  // 진행 중 링 색(주황)
  /// The in-progress ring color.
  static const Color progress = Color(0xFFF08A3C);

  // 완료 링 색(녹색)
  /// The completed ring color.
  static const Color completed = Color(0xFF5FB878);

  // 정지 버튼 배경(빨간색)
  /// The stop button background.
  static const Color stop = Color(0xFFC0473B);

  // 정지 버튼 글자(흰색)
  /// The stop button text and icon color.
  static const Color onStop = Color(0xFFFFFFFF);
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds the background, card, track, and text colors of one background preset.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 배경색 프리셋 하나의 배경·카드·바탕 면·글자 색.
class SurfacePalette {
  /// Creates a surface palette.
  const SurfacePalette({
    required this.brightness,
    required this.background,
    required this.card,
    required this.track,
    required this.textPrimary,
    required this.textSecondary,
  });

  // 어두운 배경용 글자색(기본)
  static const Color _lightText = Color(0xFFF3EDE2);
  // 어두운 배경용 보조 글자색
  static const Color _lightSecondaryText = Color(0xFFA89F90);
  // 밝은 배경용 글자색
  static const Color _darkText = Color(0xFF212121);
  // 밝은 배경용 보조 글자색
  static const Color _darkSecondaryText = Color(0xFF616161);

  // 검정(기본)
  static const SurfacePalette _black = SurfacePalette(
    // 어두운 테마
    brightness: Brightness.dark,
    // 배경
    background: Color(0xFF000000),
    // 카드
    card: Color(0xFF161616),
    // 바탕 면
    track: Color(0xFF2C2C2C),
    // 글자
    textPrimary: _lightText,
    // 보조 글자
    textSecondary: _lightSecondaryText,
  );

  // 차콜
  static const SurfacePalette _charcoal = SurfacePalette(
    // 어두운 테마
    brightness: Brightness.dark,
    // 배경
    background: Color(0xFF121212),
    // 카드
    card: Color(0xFF1E1E1E),
    // 바탕 면
    track: Color(0xFF333333),
    // 글자
    textPrimary: _lightText,
    // 보조 글자
    textSecondary: _lightSecondaryText,
  );

  // 다크 그레이(팔레트 #574)
  static const SurfacePalette _darkGray = SurfacePalette(
    // 어두운 테마
    brightness: Brightness.dark,
    // 배경 #424242
    background: Color(0xFF424242),
    // 카드
    card: Color(0xFF4F4F4F),
    // 바탕 면
    track: Color(0xFF656565),
    // 글자
    textPrimary: Color(0xFFFFFFFF),
    // 보조 글자 #E0E0E0
    textSecondary: Color(0xFFE0E0E0),
  );

  // 웜 브라운
  static const SurfacePalette _warmBrown = SurfacePalette(
    // 어두운 테마
    brightness: Brightness.dark,
    // 배경
    background: Color(0xFF17150F),
    // 카드
    card: Color(0xFF211E17),
    // 바탕 면
    track: Color(0xFF332E24),
    // 글자
    textPrimary: _lightText,
    // 보조 글자
    textSecondary: _lightSecondaryText,
  );

  // 네이비
  static const SurfacePalette _navy = SurfacePalette(
    // 어두운 테마
    brightness: Brightness.dark,
    // 배경
    background: Color(0xFF0B1220),
    // 카드
    card: Color(0xFF141C2E),
    // 바탕 면
    track: Color(0xFF25304A),
    // 글자
    textPrimary: _lightText,
    // 보조 글자
    textSecondary: _lightSecondaryText,
  );

  // 화이트(팔레트 #574)
  static const SurfacePalette _white = SurfacePalette(
    // 밝은 테마
    brightness: Brightness.light,
    // 배경 #FFFFFF
    background: Color(0xFFFFFFFF),
    // 카드
    card: Color(0xFFF2F2F2),
    // 바탕 면 #E0E0E0
    track: Color(0xFFE0E0E0),
    // 글자
    textPrimary: _darkText,
    // 보조 글자
    textSecondary: _darkSecondaryText,
  );

  // 라이트 그레이(팔레트 #574)
  static const SurfacePalette _lightGray = SurfacePalette(
    // 밝은 테마
    brightness: Brightness.light,
    // 배경 #E0E0E0
    background: Color(0xFFE0E0E0),
    // 카드
    card: Color(0xFFF5F5F5),
    // 바탕 면
    track: Color(0xFFC2C2C2),
    // 글자
    textPrimary: _darkText,
    // 보조 글자 #424242
    textSecondary: Color(0xFF424242),
  );

  /// Whether the palette is dark or light.
  final Brightness brightness;

  /// The screen background.
  final Color background;

  /// The card surface.
  final Color card;

  /// A surface one step away from [card], used for rings and bars.
  final Color track;

  /// The primary text color.
  final Color textPrimary;

  /// The secondary text color.
  final Color textSecondary;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the surface palette of a background preset.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the surface palette of [preset].
  static SurfacePalette of(BackgroundPreset preset) {
    // 프리셋별 색 묶음을 고른다.
    return switch (preset) {
      // 검정
      BackgroundPreset.black => _black,
      // 차콜
      BackgroundPreset.charcoal => _charcoal,
      // 다크 그레이
      BackgroundPreset.darkGray => _darkGray,
      // 웜 브라운
      BackgroundPreset.warmBrown => _warmBrown,
      // 네이비
      BackgroundPreset.navy => _navy,
      // 화이트
      BackgroundPreset.white => _white,
      // 라이트 그레이
      BackgroundPreset.lightGray => _lightGray,
    };
  }
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds a button/accent color and the text color placed on it.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 버튼색(포인트색)과 그 위에 올리는 글자색.
class AccentPalette {
  /// Creates an accent palette.
  const AccentPalette({required this.accent, required this.onAccent});

  // 금빛(기본)
  static const AccentPalette _gold = AccentPalette(
    // #D9A441
    accent: Color(0xFFD9A441),
    // 검정 글자
    onAccent: Color(0xFF000000),
  );

  // 블루(팔레트 #574)
  static const AccentPalette _blue = AccentPalette(
    // #1976D2
    accent: Color(0xFF1976D2),
    // 흰 글자
    onAccent: Color(0xFFFFFFFF),
  );

  // 딥 블루(팔레트 #574)
  static const AccentPalette _deepBlue = AccentPalette(
    // #1565C0
    accent: Color(0xFF1565C0),
    // 흰 글자
    onAccent: Color(0xFFFFFFFF),
  );

  // 그레이(팔레트 #574)
  static const AccentPalette _gray = AccentPalette(
    // #424242
    accent: Color(0xFF424242),
    // 흰 글자
    onAccent: Color(0xFFFFFFFF),
  );

  /// The button and accent color.
  final Color accent;

  /// The text and icon color placed on [accent].
  final Color onAccent;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the accent palette of an accent preset.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the accent palette of [preset].
  static AccentPalette of(AccentPreset preset) {
    // 프리셋별 색을 고른다.
    return switch (preset) {
      // 금빛
      AccentPreset.gold => _gold,
      // 블루
      AccentPreset.blue => _blue,
      // 딥 블루
      AccentPreset.deepBlue => _deepBlue,
      // 그레이
      AccentPreset.gray => _gray,
    };
  }
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Reads the theme-dependent accent and text colors from the current theme.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 현재 테마의 버튼색·글자색을 꺼내 쓰는 도우미.
extension ThemeColorsContext on BuildContext {
  /// The selected button/accent color.
  Color get accentColor => Theme.of(this).colorScheme.primary;

  /// The text color placed on [accentColor].
  Color get onAccentColor => Theme.of(this).colorScheme.onPrimary;

  /// The primary text color of the selected background.
  Color get textPrimaryColor => Theme.of(this).colorScheme.onSurface;

  /// The secondary text color of the selected background.
  Color get textSecondaryColor => Theme.of(this).colorScheme.onSurfaceVariant;
}
