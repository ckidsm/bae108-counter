import 'dart:io';

import 'package:bae108_counter/models/bell_sound.dart';
import 'package:bae108_counter/services/device_bow_feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sourcePathOf_everyBellSound_pointsToBundledFile', () {
    // 준비·실행: 모든 종소리의 에셋 경로를 모은다.
    final missing = <String>[
      for (final bellSound in BellSound.values)
        if (!File('assets/${FeedbackSettings.sourcePathOf(bellSound)}')
            .existsSync())
          '${bellSound.name}: ${FeedbackSettings.sourcePathOf(bellSound)}',
    ];

    // 검증: 빠진 소리 파일이 없다.
    expect(missing, isEmpty);
  });

  test('sourcePathOf_templeBell_usesTempleBellFile', () {
    // 실행·검증: 범종은 temple_bell.mp3를 쓴다.
    expect(
      FeedbackSettings.sourcePathOf(BellSound.templeBell),
      'sounds/temple_bell.mp3',
    );
  });
}
