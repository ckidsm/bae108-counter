import 'package:bae108_counter/models/bow_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson_thenFromJson_restoresSameValues', () {
    // 준비: 테스트 조건을 만든다.
    final original = BowSession(
      id: 'session-1',
      startedAt: DateTime(2026, 11, 4, 14, 2),
      endedAt: DateTime(2026, 11, 4, 14, 40),
      activeDurationSeconds: 2292,
      bowCount: 108,
      memo: '마음이 고요했다',
    );

    // 실행: 테스트 대상 동작을 수행한다.
    final restored = BowSession.fromJson(original.toJson());

    // 검증: 기대 결과를 확인한다.
    expect(restored.id, original.id);
    expect(restored.startedAt, original.startedAt);
    expect(restored.endedAt, original.endedAt);
    expect(restored.activeDurationSeconds, original.activeDurationSeconds);
    expect(restored.bowCount, original.bowCount);
    expect(restored.memo, original.memo);
  });

  test('fromJson_missingRequiredField_throwsFormatException', () {
    // 준비 및 실행: 대상을 만들고 동작을 수행한다.
    final invalidJson = <String, dynamic>{'id': 'session-1'};

    // 검증: 기대 결과를 확인한다.
    expect(() => BowSession.fromJson(invalidJson), throwsFormatException);
  });
}
