import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/bow_session.dart';
import '../models/counter_settings.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the shared_preferences keys used by the app.
 Remarks  : The version suffix allows a future format migration.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// shared_preferences 저장 키.
abstract final class PreferenceKeys {
  // 수행 기록 목록(JSON 배열 문자열)을 저장하는 키
  /// The key storing the practice records as a JSON array string.
  static const String bowSessions = 'bow_sessions_v1';

  // 카운터 설정(JSON 객체 문자열)을 저장하는 키
  /// The key storing the counter settings as a JSON object string.
  static const String counterSettings = 'counter_settings_v1';

  // 앱 설정(테마·캘린더, JSON 객체 문자열)을 저장하는 키
  /// The key storing the app settings as a JSON object string.
  static const String appSettings = 'app_settings_v1';
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Stores practice records and counter settings as JSON in shared_preferences.
 Remarks  : Corrupted stored JSON is logged and treated as empty instead of crashing.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 수행 기록과 설정을 shared_preferences에 JSON으로 저장하는 저장소.
final class PracticeRecordRepository {
  /// Creates a repository backed by [preferences].
  PracticeRecordRepository(this._preferences);

  // 실제 값을 읽고 쓰는 shared_preferences 인스턴스
  final SharedPreferences _preferences;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Loads all stored practice records, newest first.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Loads all stored practice records, newest first.
  List<BowSession> loadSessions() {
    // 저장된 JSON 문자열을 읽는다.
    final storedJson = _preferences.getString(PreferenceKeys.bowSessions);
    // 저장된 값이 없으면 빈 목록을 돌려준다.
    if (storedJson == null) {
      // 아직 기록이 없다.
      return <BowSession>[];
    }
    // 저장 데이터가 깨졌을 수 있으므로 형식 오류를 처리한다.
    try {
      // JSON 배열을 디코딩한다.
      final decodedItems = jsonDecode(storedJson) as List<dynamic>;
      // 각 항목을 기록 객체로 바꾼다.
      final sessions = decodedItems
          // 항목을 Map으로 보고 기록 객체를 만든다.
          .map((item) => BowSession.fromJson(item as Map<String, dynamic>))
          // 목록으로 만든다.
          .toList();
      // 최근 기록이 앞에 오도록 종료 시각 내림차순으로 정렬한다.
      sessions.sort((left, right) => right.endedAt.compareTo(left.endedAt));
      // 정렬된 기록을 돌려준다.
      return sessions;
    } on FormatException catch (error) {
      // 어떤 키의 데이터가 깨졌는지 남긴다(원본 값은 기록하지 않는다).
      debugPrint(
        '[PracticeRecordRepository] 기록 JSON 해석 실패 ${PreferenceKeys.bowSessions}: $error',
      );
      // 앱이 멈추지 않도록 빈 목록으로 처리한다.
      return <BowSession>[];
    } on TypeError catch (error) {
      // JSON 구조가 예상과 다를 때도 원인을 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 기록 JSON 구조 오류 ${PreferenceKeys.bowSessions}: $error',
      );
      // 앱이 멈추지 않도록 빈 목록으로 처리한다.
      return <BowSession>[];
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Adds one practice record to storage.
   Remarks  : Throws StateError when shared_preferences reports a failed write.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Adds [session] to the stored records.
  ///
  /// Throws a [StateError] when the value could not be written.
  Future<void> addSession(BowSession session) async {
    // 기존 기록 뒤에 새 기록을 붙인다.
    final sessions = <BowSession>[...loadSessions(), session];
    // 전체 목록을 JSON 문자열로 바꾼다.
    final encodedJson = jsonEncode(
      // 각 기록을 Map으로 바꾼다.
      sessions.map((item) => item.toJson()).toList(),
    );
    // 저장하고 성공 여부를 받는다.
    final isSaved = await _preferences.setString(
      PreferenceKeys.bowSessions,
      encodedJson,
    );
    // 저장에 실패하면 호출한 화면에서 알릴 수 있도록 예외를 던진다.
    if (!isSaved) {
      // 실패한 저장 키를 포함해 알린다.
      throw StateError('수행 기록 저장 실패: ${PreferenceKeys.bowSessions}');
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Loads the counter settings, or the given defaults when none are stored.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Loads the stored counter settings, or [fallback] when none are stored.
  CounterSettings loadSettings(CounterSettings fallback) {
    // 저장된 설정 JSON을 읽는다.
    final storedJson = _preferences.getString(PreferenceKeys.counterSettings);
    // 저장된 설정이 없으면 기본값을 쓴다.
    if (storedJson == null) {
      // 기본 설정을 돌려준다.
      return fallback;
    }
    // 설정 데이터가 깨졌을 수 있으므로 형식 오류를 처리한다.
    try {
      // JSON 객체를 설정으로 바꾼다.
      return CounterSettings.fromJson(
        jsonDecode(storedJson) as Map<String, dynamic>,
        fallback,
      );
    } on FormatException catch (error) {
      // 해석 실패 원인을 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 설정 JSON 해석 실패 ${PreferenceKeys.counterSettings}: $error',
      );
      // 기본 설정으로 계속 진행한다.
      return fallback;
    } on TypeError catch (error) {
      // 구조 오류 원인을 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 설정 JSON 구조 오류 ${PreferenceKeys.counterSettings}: $error',
      );
      // 기본 설정으로 계속 진행한다.
      return fallback;
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Stores the counter settings.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Stores [settings] so they are restored on the next launch.
  Future<void> saveSettings(CounterSettings settings) async {
    // 설정을 JSON 문자열로 저장한다.
    final isSaved = await _preferences.setString(
      PreferenceKeys.counterSettings,
      jsonEncode(settings.toJson()),
    );
    // 설정 저장 실패는 다음 실행에 기본값을 쓰는 정도의 영향이므로 기록만 남긴다.
    if (!isSaved) {
      // 실패한 키를 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 설정 저장 실패 ${PreferenceKeys.counterSettings}',
      );
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Loads the app-wide settings, or defaults when none are stored.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Loads the stored app settings, or the defaults when none are stored.
  AppSettings loadAppSettings() {
    // 저장된 앱 설정 JSON을 읽는다.
    final storedJson = _preferences.getString(PreferenceKeys.appSettings);
    // 저장된 값이 없으면 기본값을 쓴다.
    if (storedJson == null) {
      // 기본 앱 설정
      return const AppSettings();
    }
    // 설정 데이터가 깨졌을 수 있으므로 형식 오류를 처리한다.
    try {
      // JSON 객체를 앱 설정으로 바꾼다.
      return AppSettings.fromJson(
        jsonDecode(storedJson) as Map<String, dynamic>,
      );
    } on FormatException catch (error) {
      // 해석 실패 원인을 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 앱 설정 JSON 해석 실패 ${PreferenceKeys.appSettings}: $error',
      );
      // 기본 설정으로 계속 진행한다.
      return const AppSettings();
    } on TypeError catch (error) {
      // 구조 오류 원인을 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 앱 설정 JSON 구조 오류 ${PreferenceKeys.appSettings}: $error',
      );
      // 기본 설정으로 계속 진행한다.
      return const AppSettings();
    }
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Stores the app-wide settings.
   Author   : YUNDEOKSOO                        Created : 2026-11-04
  ──────────────────────────────────────────────────────────────────────*/
  /// Stores [settings] so they are restored on the next launch.
  Future<void> saveAppSettings(AppSettings settings) async {
    // 앱 설정을 JSON 문자열로 저장한다.
    final isSaved = await _preferences.setString(
      PreferenceKeys.appSettings,
      jsonEncode(settings.toJson()),
    );
    // 저장 실패는 다음 실행에 기본값을 쓰는 정도의 영향이므로 기록만 남긴다.
    if (!isSaved) {
      // 실패한 키를 남긴다.
      debugPrint(
        '[PracticeRecordRepository] 앱 설정 저장 실패 ${PreferenceKeys.appSettings}',
      );
    }
  }
}
