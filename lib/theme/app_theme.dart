import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/accent_preset.dart';
import '../models/background_preset.dart';
import 'app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Builds the Material 3 theme from the selected background and button colors.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 선택한 배경색과 버튼색으로 Material 3 테마를 만든다.
abstract final class AppTheme {
  // 카드와 버튼 모서리 반지름
  static const double _cornerRadius = 16;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Creates the Material 3 theme for a background and accent preset.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Creates the Material 3 theme for [backgroundPreset] and [accentPreset].
  static ThemeData build(
    BackgroundPreset backgroundPreset,
    AccentPreset accentPreset,
  ) {
    // 배경·카드·바탕 면·글자 색
    final surface = SurfacePalette.of(backgroundPreset);
    // 버튼색과 그 위 글자색
    final accent = AccentPalette.of(accentPreset);
    // 버튼색을 기준으로 색 구성을 만들고 지정 색으로 덮어쓴다.
    final colorScheme =
        ColorScheme.fromSeed(
          // 기준색
          seedColor: accent.accent,
          // 배경 밝기(밝은 배경이면 라이트 테마)
          brightness: surface.brightness,
        ).copyWith(
          // 주요 강조색(버튼색)
          primary: accent.accent,
          // 버튼 위 글자색
          onPrimary: accent.onAccent,
          // 기본 면 색은 배경색
          surface: surface.background,
          // 면 위 글자색
          onSurface: surface.textPrimary,
          // 보조 글자색
          onSurfaceVariant: surface.textSecondary,
          // 카드 면 색
          surfaceContainer: surface.card,
          // 카드와 구분되는 바탕 면 색
          surfaceContainerHighest: surface.track,
          // 세그먼트 버튼 선택 배경
          secondaryContainer: surface.track,
          // 세그먼트 버튼 선택 글자(버튼색)
          onSecondaryContainer: accent.accent,
          // 테두리 색
          outline: surface.track,
          // 옅은 테두리 색
          outlineVariant: surface.track,
        );
    // 모서리를 둥글게 만드는 공통 모양
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
    );
    // 밝은 배경이면 상태바 아이콘을 어둡게, 어두운 배경이면 밝게 한다.
    final systemOverlayStyle = surface.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    // 테마 데이터를 만든다.
    return ThemeData(
      // Material 3 사용
      useMaterial3: true,
      // 위에서 만든 색 구성
      colorScheme: colorScheme,
      // 화면 배경색
      scaffoldBackgroundColor: surface.background,
      // 상단 바 스타일
      appBarTheme: AppBarTheme(
        // 배경과 같은 색
        backgroundColor: surface.background,
        // 글자색
        foregroundColor: surface.textPrimary,
        // 스크롤 시 색이 바뀌지 않게 한다.
        scrolledUnderElevation: 0,
        // 상태바 아이콘 밝기
        systemOverlayStyle: systemOverlayStyle,
      ),
      // 카드 스타일
      cardTheme: CardThemeData(
        // 카드 색
        color: surface.card,
        // 그림자 없음
        elevation: 0,
        // 바깥 여백 없음(화면에서 직접 지정)
        margin: EdgeInsets.zero,
        // 둥근 모서리
        shape: roundedShape,
      ),
      // 채워진 버튼 스타일
      filledButtonTheme: FilledButtonThemeData(
        // 둥근 모서리
        style: FilledButton.styleFrom(shape: roundedShape),
      ),
      // 테두리 버튼 스타일
      outlinedButtonTheme: OutlinedButtonThemeData(
        // 둥근 모서리와 버튼색 글자
        style: OutlinedButton.styleFrom(
          // 둥근 모서리
          shape: roundedShape,
          // 버튼색 글자
          foregroundColor: accent.accent,
          // 테두리 색
          side: BorderSide(color: surface.track),
        ),
      ),
      // 스위치 스타일(꺼진 상태도 카드 위에서 보이도록 보조 글자색 손잡이·테두리)
      switchTheme: SwitchThemeData(
        // 손잡이 색: 켜짐은 버튼 위 글자색, 꺼짐은 보조 글자색
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent.onAccent
              : surface.textSecondary,
        ),
        // 트랙 색: 켜짐은 버튼색, 꺼짐은 바탕 면 색
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent.accent
              : surface.track,
        ),
        // 트랙 테두리: 꺼짐일 때 보조 글자색
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent.accent
              : surface.textSecondary,
        ),
      ),
      // 하단 시트 스타일
      bottomSheetTheme: BottomSheetThemeData(
        // 카드 색 배경
        backgroundColor: surface.card,
      ),
      // 하단 알림(스낵바) 스타일
      snackBarTheme: SnackBarThemeData(
        // 바탕 면 색 배경
        backgroundColor: surface.track,
        // 기본 글자색
        contentTextStyle: TextStyle(color: surface.textPrimary),
        // 화면 아래에서 띄워 표시
        behavior: SnackBarBehavior.floating,
      ),
      // 대화상자 스타일
      dialogTheme: DialogThemeData(
        // 카드 색 배경
        backgroundColor: surface.card,
      ),
    );
  }
}
