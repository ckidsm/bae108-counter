import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../theme/screen_layout.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Locks tablets to landscape and phones to portrait on iOS and Android.
 Remarks  : iOS also limits orientations in Info.plist; this keeps Android the same.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 태블릿은 가로, 휴대폰은 세로로 화면 방향을 고정한다.
abstract final class ScreenOrientationService {
  // 태블릿 허용 방향(가로 두 방향)
  static const List<DeviceOrientation> _tabletOrientations =
      <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];

  // 휴대폰 허용 방향(세로)
  static const List<DeviceOrientation> _phoneOrientations = <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ];

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Returns the allowed orientations for a screen of the given logical size.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the orientations allowed for a screen of [logicalSize].
  static List<DeviceOrientation> orientationsFor(Size logicalSize) {
    // 태블릿이면 가로, 아니면 세로
    return ScreenLayout.isTablet(logicalSize)
        ? _tabletOrientations
        : _phoneOrientations;
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Applies the orientation lock for the current screen.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Locks the orientation for a screen of [logicalSize].
  static Future<void> apply(Size logicalSize) async {
    // 플랫폼 호출은 실패할 수 있다.
    try {
      // 허용 방향을 설정한다.
      await SystemChrome.setPreferredOrientations(orientationsFor(logicalSize));
    } on PlatformException catch (error) {
      // 실패해도 앱은 계속 쓸 수 있으므로 원인만 남긴다.
      debugPrint('[ScreenOrientation] 방향 고정 실패: $error');
    }
  }
}
