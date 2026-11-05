import 'dart:ui';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines the screen-size breakpoints shared by orientation and layout.
 Remarks  : Tablets (iPad, Android tablets) are landscape-only and use the
            three-column layout; phones are portrait-only.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 휴대폰·태블릿을 나누고 3단 화면을 쓸지 정하는 화면 크기 기준.
abstract final class ScreenLayout {
  // 태블릿으로 보는 화면 짧은 변의 최소 길이(논리 픽셀, Android 태블릿 기준과 같음)
  /// The shortest side, in logical pixels, from which a device is a tablet.
  static const double tabletShortestSide = 600;

  // 3단 화면을 쓰는 최소 폭(논리 픽셀)
  /// The minimum width, in logical pixels, for the three-column layout.
  static const double wideLayoutMinWidth = 900;

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Tells whether a screen of the given logical size is a tablet.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Whether a screen of [logicalSize] is a tablet.
  static bool isTablet(Size logicalSize) {
    // 짧은 변이 기준 이상이면 태블릿
    return logicalSize.shortestSide >= tabletShortestSide;
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Tells whether the three-column landscape layout fits the given size.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Whether [size] is wide and landscape enough for the three-column layout.
  static bool useWideLayout(Size size) {
    // 충분히 넓고 가로가 더 길어야 한다.
    return size.width >= wideLayoutMinWidth && size.width > size.height;
  }
}
