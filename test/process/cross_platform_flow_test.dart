import 'package:bae108_counter/controllers/counter_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// 테스트에서 쓰는 절 간격(초)
const int _intervalSeconds = 5;

// 검사할 기기 화면(휴대폰 세로, 태블릿 가로)
const Map<String, Size> _devices = <String, Size>{
  '휴대폰': phoneSize,
  'Android 휴대폰': androidPhoneSize,
  'iPad 가로': iPadLandscapeSize,
  'Android 태블릿 가로': androidTabletLandscapeSize,
};

void main() {
  for (final device in _devices.entries) {
    testWidgets('fullPractice_${device.key}_counts108AndSavesRecord', (
      tester,
    ) async {
      // 준비: 5초 간격이 저장된 앱을 기기 크기로 띄운다.
      final testApp = await pumpTestApp(
        tester,
        logicalSize: device.value,
        intervalSeconds: _intervalSeconds,
      );
      expect(tester.takeException(), isNull);

      // 실행 1: 시작해서 준비 10초가 끝나면 1배를 시작한다.
      await tester.tap(find.text('시작'));
      await advanceSeconds(tester, CounterRules.preparationSeconds);
      expect(find.text('1'), findsOneWidget);

      // 실행 2: 절마다 숫자가 1씩 올라 108배째까지 간다(매 절 확인).
      for (
        var bowNumber = 2;
        bowNumber <= CounterRules.targetBowCount;
        bowNumber++
      ) {
        await tester.pump(const Duration(seconds: _intervalSeconds));
        expect(find.text('$bowNumber'), findsOneWidget, reason: '$bowNumber배');
      }
      expect(testApp.wakeLockService.isEnabled, isTrue);

      // 실행 3: 108배째 간격이 끝나면 완료되고 회향 화면이 열린다.
      await tester.pump(const Duration(seconds: _intervalSeconds));
      expect(find.text('108배를 모두 마쳤습니다'), findsOneWidget);
      expect(testApp.wakeLockService.isEnabled, isFalse);
      expect(
        testApp.feedbackService.calls,
        hasLength(CounterRules.targetBowCount + 1),
      );
      expect(
        testApp.feedbackService.calls.where((call) => call.isFinalBow),
        hasLength(1),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('108배 회향'), findsOneWidget);

      // 실행 4: 기록을 저장하고 돌아온다.
      await tester.tap(find.text('기록 저장'));
      await tester.pumpAndSettle();

      // 검증: 기록 1건(108배, 실제 수행 시간 = 간격 x 108)이 저장되고 0으로 돌아온다.
      final session = testApp.repository.loadSessions().single;
      expect(session.bowCount, CounterRules.targetBowCount);
      expect(
        session.activeDurationSeconds,
        _intervalSeconds * CounterRules.targetBowCount,
      );
      expect(find.text('0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('fullPractice_${device.key}_iOS_counts108AndSavesRecord', (
      tester,
    ) async {
      // 준비: iOS로 같은 흐름을 빠르게 확인한다.
      final testApp = await pumpTestApp(
        tester,
        logicalSize: device.value,
        intervalSeconds: _intervalSeconds,
      );

      // 실행: 108배를 끝까지 진행하고 저장한다.
      await runPracticeToCompletion(tester, intervalSeconds: _intervalSeconds);
      expect(find.text('108배 회향'), findsOneWidget);
      await tester.tap(find.text('기록 저장'));
      await tester.pumpAndSettle();

      // 검증: 기록이 저장되고 넘침 오류가 없다.
      expect(testApp.repository.loadSessions(), hasLength(1));
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  }
}
