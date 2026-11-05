import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'controllers/app_settings_controller.dart';
import 'services/device_bow_feedback_service.dart';
import 'services/device_calendar_sync_service.dart';
import 'services/method_channel_watch_sync_service.dart';
import 'services/practice_record_repository.dart';
import 'services/screen_orientation_service.dart';
import 'services/wake_lock_service.dart';
import 'services/watch_sync_service.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Starts the app after loading shared_preferences.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// Starts the 108-bow counter app.
Future<void> main() async {
  // 플러그인을 쓰기 전에 Flutter 엔진을 준비한다.
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // 첫 화면의 논리 크기(태블릿인지 판단용)
  final view = binding.platformDispatcher.views.first;
  // 태블릿은 가로, 휴대폰은 세로로 고정한다.
  await ScreenOrientationService.apply(
    view.physicalSize / view.devicePixelRatio,
  );
  // 기록과 설정을 읽을 저장소를 연다.
  final preferences = await SharedPreferences.getInstance();
  // shared_preferences 기반 저장소
  final repository = PracticeRecordRepository(preferences);
  // 앱을 실행한다.
  runApp(
    Bae108App(
      // 기록 저장소
      repository: repository,
      // 실제 기기 소리·진동 서비스
      feedbackService: DeviceBowFeedbackService(),
      // wakelock_plus 기반 화면 켜짐 서비스
      wakeLockService: const PluginWakeLockService(),
      // 저장된 테마·캘린더 설정
      appSettingsController: AppSettingsController(repository),
      // 기기 캘린더(Google 계정 캘린더 포함) 서비스
      calendarSyncService: DeviceCalendarSyncService(),
      // iOS에서만 Apple Watch 연동, 그 외 플랫폼은 빈 구현
      watchSyncService: defaultTargetPlatform == TargetPlatform.iOS
          ? MethodChannelWatchSyncService()
          : const NoopWatchSyncService(),
    ),
  );
}
