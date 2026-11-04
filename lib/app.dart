import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/bow_feedback_service.dart';
import 'services/practice_record_repository.dart';
import 'services/wake_lock_service.dart';
import 'theme/app_theme.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Configures the theme, localization, and first screen of the app.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 108배 카운터 앱의 최상위 위젯.
class Bae108App extends StatelessWidget {
  /// Creates the app with its services.
  const Bae108App({
    super.key,
    required this.repository,
    required this.feedbackService,
    required this.wakeLockService,
  });

  /// Stores practice records and settings.
  final PracticeRecordRepository repository;

  /// Plays the per-bow feedback.
  final BowFeedbackService feedbackService;

  /// Keeps the screen on during a practice.
  final WakeLockService wakeLockService;

  @override
  Widget build(BuildContext context) {
    // 앱 설정
    return MaterialApp(
      // 앱 전환기에 보이는 이름(번역 문구)
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // 디버그 띠 숨김
      debugShowCheckedModeBanner: false,
      // 다크 테마
      theme: AppTheme.buildDarkTheme(),
      // 항상 다크 모드
      themeMode: ThemeMode.dark,
      // 앱 번역과 Material·Cupertino 기본 번역
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        // 앱 문구
        AppLocalizations.delegate,
        // Material 위젯 문구
        GlobalMaterialLocalizations.delegate,
        // 기본 위젯 문구
        GlobalWidgetsLocalizations.delegate,
        // Cupertino 위젯 문구
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원 언어
      supportedLocales: AppLocalizations.supportedLocales,
      // 첫 화면
      home: MainScreen(
        // 저장소
        repository: repository,
        // 알림 서비스
        feedbackService: feedbackService,
        // 화면 켜짐 서비스
        wakeLockService: wakeLockService,
      ),
    );
  }
}
