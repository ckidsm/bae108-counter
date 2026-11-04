import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:bae108_counter/models/alert_mode.dart';
import 'package:bae108_counter/models/bow_session.dart';
import 'package:bae108_counter/models/count_mode.dart';
import 'package:bae108_counter/models/counter_settings.dart';
import 'package:bae108_counter/services/practice_record_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 지정한 시각에 끝난 기록을 만든다.
BowSession _sessionEndingAt(DateTime endedAt) {
  // 30분짜리 108배 기록
  return BowSession(
    id: endedAt.toIso8601String(),
    startedAt: endedAt.subtract(const Duration(minutes: 30)),
    endedAt: endedAt,
    activeDurationSeconds: const Duration(minutes: 30).inSeconds,
    bowCount: CounterRules.targetBowCount,
  );
}

void main() {
  // 저장된 값으로 테스트용 저장소를 만든다.
  Future<PracticeRecordRepository> createRepository([
    Map<String, Object> initialValues = const <String, Object>{},
  ]) async {
    // shared_preferences를 메모리 값으로 대체한다.
    SharedPreferences.setMockInitialValues(initialValues);
    // 메모리 기반 저장소
    return PracticeRecordRepository(await SharedPreferences.getInstance());
  }

  test('addSession_twoRecords_loadsNewestFirst', () async {
    // 준비: 테스트 조건을 만든다.
    final repository = await createRepository();
    final olderSession = _sessionEndingAt(DateTime(2026, 11, 3, 7));
    final newerSession = _sessionEndingAt(DateTime(2026, 11, 4, 7));

    // 실행: 테스트 대상 동작을 수행한다.
    await repository.addSession(olderSession);
    await repository.addSession(newerSession);
    final sessions = repository.loadSessions();

    // 검증: 기대 결과를 확인한다.
    expect(sessions.map((session) => session.id), <String>[
      newerSession.id,
      olderSession.id,
    ]);
  });

  test('loadSessions_corruptedJson_returnsEmptyList', () async {
    // 준비: 테스트 조건을 만든다.
    final repository = await createRepository(<String, Object>{
      PreferenceKeys.bowSessions: '{not json',
    });

    // 실행: 테스트 대상 동작을 수행한다.
    final sessions = repository.loadSessions();

    // 검증: 기대 결과를 확인한다.
    expect(sessions, isEmpty);
  });

  test('saveSettings_thenLoadSettings_restoresSavedOptions', () async {
    // 준비: 테스트 조건을 만든다.
    final repository = await createRepository();
    const savedSettings = CounterSettings(
      countMode: CountMode.auto,
      intervalSeconds: 45,
      alertMode: AlertMode.vibration,
    );

    // 실행: 테스트 대상 동작을 수행한다.
    await repository.saveSettings(savedSettings);
    final loadedSettings = repository.loadSettings(
      CounterRules.defaultSettings,
    );

    // 검증: 기대 결과를 확인한다.
    expect(loadedSettings.countMode, CountMode.auto);
    expect(loadedSettings.intervalSeconds, 45);
    expect(loadedSettings.alertMode, AlertMode.vibration);
  });

  test('loadSettings_nothingStored_returnsFallback', () async {
    // 준비: 테스트 조건을 만든다.
    final repository = await createRepository();

    // 실행: 테스트 대상 동작을 수행한다.
    final loadedSettings = repository.loadSettings(
      CounterRules.defaultSettings,
    );

    // 검증: 기대 결과를 확인한다.
    expect(loadedSettings.countMode, CounterRules.defaultSettings.countMode);
    expect(loadedSettings.intervalSeconds, CounterRules.defaultIntervalSeconds);
  });
}
