import 'package:flutter/material.dart';

import 'app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Builds the Material 3 dark theme from the app palette.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// Material 3 다크 테마를 만든다.
abstract final class AppTheme {
  // 카드와 버튼 모서리 반지름
  static const double _cornerRadius = 16;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Creates the dark Material 3 theme used by the whole app.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Creates the dark Material 3 theme.
  static ThemeData buildDarkTheme() {
    // 금빛을 기준색으로 다크 색 구성을 만들고 지정 색으로 덮어쓴다.
    final colorScheme =
        ColorScheme.fromSeed(
          // 기준색
          seedColor: AppColors.gold,
          // 다크 모드
          brightness: Brightness.dark,
        ).copyWith(
          // 주요 강조색은 금빛
          primary: AppColors.gold,
          // 금빛 위 글자색
          onPrimary: AppColors.onGold,
          // 기본 면 색은 화면 배경색
          surface: AppColors.background,
          // 면 위 글자색
          onSurface: AppColors.textPrimary,
          // 보조 글자색
          onSurfaceVariant: AppColors.textSecondary,
          // 카드 면 색
          surfaceContainer: AppColors.card,
          // 카드보다 밝은 면 색
          surfaceContainerHighest: AppColors.track,
          // 세그먼트 버튼 선택 배경
          secondaryContainer: AppColors.track,
          // 세그먼트 버튼 선택 글자
          onSecondaryContainer: AppColors.gold,
          // 테두리 색
          outline: AppColors.track,
          // 옅은 테두리 색
          outlineVariant: AppColors.track,
        );
    // 모서리를 둥글게 만드는 공통 모양
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
    );
    // 테마 데이터를 만든다.
    return ThemeData(
      // Material 3 사용
      useMaterial3: true,
      // 위에서 만든 색 구성
      colorScheme: colorScheme,
      // 화면 배경색
      scaffoldBackgroundColor: AppColors.background,
      // 상단 바 스타일
      appBarTheme: const AppBarTheme(
        // 배경과 같은 색
        backgroundColor: AppColors.background,
        // 글자색
        foregroundColor: AppColors.textPrimary,
        // 스크롤 시 색이 바뀌지 않게 한다.
        scrolledUnderElevation: 0,
      ),
      // 카드 스타일
      cardTheme: CardThemeData(
        // 카드 색
        color: AppColors.card,
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
        // 둥근 모서리와 금빛 글자
        style: OutlinedButton.styleFrom(
          // 둥근 모서리
          shape: roundedShape,
          // 금빛 글자
          foregroundColor: AppColors.gold,
          // 테두리 색
          side: const BorderSide(color: AppColors.track),
        ),
      ),
      // 하단 시트 스타일
      bottomSheetTheme: const BottomSheetThemeData(
        // 카드 색 배경
        backgroundColor: AppColors.card,
      ),
      // 하단 알림(스낵바) 스타일
      snackBarTheme: const SnackBarThemeData(
        // 카드보다 밝은 면 색 배경
        backgroundColor: AppColors.track,
        // 기본 글자색
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        // 화면 아래에서 띄워 표시
        behavior: SnackBarBehavior.floating,
      ),
      // 대화상자 스타일
      dialogTheme: const DialogThemeData(
        // 카드 색 배경
        backgroundColor: AppColors.card,
      ),
    );
  }
}
