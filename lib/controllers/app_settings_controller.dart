import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/accent_preset.dart';
import '../models/background_preset.dart';
import '../models/calendar_target.dart';
import '../services/practice_record_repository.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Holds app-wide settings and stores every change immediately.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 테마와 캘린더 기록 설정을 관리하고 바뀔 때마다 저장한다.
class AppSettingsController extends ChangeNotifier {
  /// Creates the controller with the settings stored in [_repository].
  AppSettingsController(this._repository)
    : _settings = _repository.loadAppSettings();

  // 설정을 읽고 쓰는 저장소
  final PracticeRecordRepository _repository;
  // 현재 설정
  AppSettings _settings;

  /// The current settings.
  AppSettings get settings => _settings;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Changes the background color.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Changes the background color to [backgroundPreset].
  void setBackgroundPreset(BackgroundPreset backgroundPreset) {
    // 배경색만 바꿔 적용한다.
    _apply(_settings.copyWith(backgroundPreset: backgroundPreset));
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Changes the button/accent color.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Changes the button/accent color to [accentPreset].
  void setAccentPreset(AccentPreset accentPreset) {
    // 버튼색만 바꿔 적용한다.
    _apply(_settings.copyWith(accentPreset: accentPreset));
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Turns calendar recording on for a calendar.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Turns calendar recording on and records to [calendarTarget].
  void enableCalendarSync(CalendarTarget calendarTarget) {
    // 켜고 캘린더를 지정한다.
    _apply(
      _settings.copyWith(
        isCalendarSyncEnabled: true,
        calendarTarget: calendarTarget,
      ),
    );
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Turns calendar recording off while remembering the last calendar.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Turns calendar recording off. The chosen calendar is remembered.
  void disableCalendarSync() {
    // 끄기만 하고 마지막 캘린더는 남겨 둔다.
    _apply(_settings.copyWith(isCalendarSyncEnabled: false));
  }

  // 새 설정을 반영하고 저장한 뒤 화면에 알린다.
  void _apply(AppSettings settings) {
    // 현재 설정을 바꾼다.
    _settings = settings;
    // 저장한다(완료를 기다리지 않는다).
    unawaited(_repository.saveAppSettings(settings));
    // 화면을 다시 그리도록 알린다.
    notifyListeners();
  }
}
