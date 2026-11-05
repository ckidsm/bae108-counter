import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/app_settings_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/bow_feedback_service.dart';
import 'services/calendar_sync_service.dart';
import 'services/practice_record_repository.dart';
import 'services/wake_lock_service.dart';
import 'services/watch_sync_service.dart';
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
    required this.appSettingsController,
    required this.calendarSyncService,
    this.watchSyncService = const NoopWatchSyncService(),
  });

  /// Stores practice records and settings.
  final PracticeRecordRepository repository;

  /// Plays the per-bow feedback.
  final BowFeedbackService feedbackService;

  /// Keeps the screen on during a practice.
  final WakeLockService wakeLockService;

  /// Holds the theme and calendar settings.
  final AppSettingsController appSettingsController;

  /// Adds saved records to the device calendar.
  final CalendarSyncService calendarSyncService;

  /// Syncs settings and records with the Apple Watch app.
  final WatchSyncService watchSyncService;

  @override
  Widget build(BuildContext context) {
    // 테마 설정이 바뀌면 앱 전체를 다시 그린다.
    return ListenableBuilder(
      // 감시 대상
      listenable: appSettingsController,
      // 앱
      builder: (context, _) => _buildMaterialApp(),
    );
  }

  // 테마·번역·첫 화면을 설정한 MaterialApp
  Widget _buildMaterialApp() {
    // 앱 설정
    return MaterialApp(
      // 앱 전환기에 보이는 이름(번역 문구)
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // 디버그 띠 숨김
      debugShowCheckedModeBanner: false,
      // 선택한 배경 프리셋의 다크 테마
      theme: AppTheme.build(
        appSettingsController.settings.backgroundPreset,
        appSettingsController.settings.accentPreset,
      ),
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
        // 앱 설정
        appSettingsController: appSettingsController,
        // 캘린더 서비스
        calendarSyncService: calendarSyncService,
        // Apple Watch 연동 서비스
        watchSyncService: watchSyncService,
      ),
    );
  }
}
