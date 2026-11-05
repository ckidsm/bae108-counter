import 'package:bae108_counter/services/screen_orientation_service.dart';
import 'package:bae108_counter/theme/screen_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  // 휴대폰으로 판정되어야 하는 크기(세로·가로 모두)
  const phones = <String, Size>{
    'iPhone 세로': phoneSize,
    'iPhone 가로': Size(844, 390),
    'iPhone SE': smallPhoneSize,
    'Android 휴대폰': androidPhoneSize,
  };
  // 태블릿으로 판정되어야 하는 크기(세로·가로 모두)
  const tablets = <String, Size>{
    'iPad Pro 11 가로': iPadLandscapeSize,
    'iPad Pro 11 세로': Size(834, 1194),
    'iPad 10.2 가로': smallIPadLandscapeSize,
    'Android 10인치 가로': androidTabletLandscapeSize,
    'Android 7인치 가로': smallAndroidTabletLandscapeSize,
  };

  test('orientationsFor_phones_allowsPortraitOnly', () {
    // 실행 및 검증: 모든 휴대폰은 세로만 허용한다.
    for (final entry in phones.entries) {
      expect(
        ScreenOrientationService.orientationsFor(entry.value),
        <DeviceOrientation>[DeviceOrientation.portraitUp],
        reason: entry.key,
      );
    }
  });

  test('orientationsFor_tablets_allowsLandscapeOnly', () {
    // 실행 및 검증: 모든 태블릿은 가로 두 방향만 허용한다(세로로 들고 있어도).
    for (final entry in tablets.entries) {
      expect(
        ScreenOrientationService.orientationsFor(entry.value),
        <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        reason: entry.key,
      );
    }
  });

  test('useWideLayout_tabletLandscape_isTrue', () {
    // 실행 및 검증: 태블릿 가로 크기는 모두 3단 화면을 쓴다.
    for (final size in <Size>[
      iPadLandscapeSize,
      smallIPadLandscapeSize,
      androidTabletLandscapeSize,
      smallAndroidTabletLandscapeSize,
    ]) {
      expect(ScreenLayout.useWideLayout(size), isTrue, reason: '$size');
    }
  });

  test('useWideLayout_phonesAndPortrait_isFalse', () {
    // 실행 및 검증: 휴대폰과 세로 화면은 휴대폰 화면을 쓴다.
    for (final size in <Size>[
      phoneSize,
      const Size(844, 390),
      androidPhoneSize,
      const Size(834, 1194),
    ]) {
      expect(ScreenLayout.useWideLayout(size), isFalse, reason: '$size');
    }
  });
}
