import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the round ascetic Buddha emblem next to the main title.
 Remarks  : The SVG is built at runtime so it follows the selected button
            and background colors.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 메인 제목 옆에 붙는 원형 고행상 엠블럼.
class AsceticEmblem extends StatelessWidget {
  /// Creates the emblem with the given [size].
  const AsceticEmblem({super.key, this.size = _defaultSize});

  // 기본 크기(논리 픽셀)
  static const double _defaultSize = 56;

  // 그림 색 자리 표시자
  static const String _figureColorToken = '{figure}';

  // 바탕 색 자리 표시자
  static const String _backgroundColorToken = '{background}';

  // 1024x1024 기준 엠블럼 SVG(바탕 원, 이중 테두리, 갈비뼈가 드러난 좌상)
  static const String _svgTemplate = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
<circle cx="512" cy="512" r="470" fill="{background}"/>
<circle cx="512" cy="512" r="440" fill="none" stroke="{figure}" stroke-width="28"/>
<circle cx="512" cy="512" r="395" fill="none" stroke="{figure}" stroke-width="8" opacity="0.6"/>
<g transform="translate(512 540) scale(0.72) translate(-512 -540)">
<g fill="{figure}">
<circle cx="512" cy="262" r="30"/>
<ellipse cx="512" cy="368" rx="66" ry="84"/>
<rect x="490" y="440" width="44" height="40" rx="12"/>
<path d="M392 492 Q512 455 632 492 L620 560 Q600 640 590 690 L434 690 Q424 640 404 560 Z"/>
<path d="M392 492 Q356 520 352 600 Q350 660 396 700 L430 690 Q398 640 410 560 Z"/>
<path d="M632 492 Q668 520 672 600 Q674 660 628 700 L594 690 Q626 640 614 560 Z"/>
<path d="M250 790 Q270 690 420 690 L604 690 Q754 690 774 790 Q770 820 720 822 L304 822 Q254 820 250 790 Z"/>
</g>
<g fill="none" stroke="{background}" stroke-width="9" stroke-linecap="round">
<path d="M450 530 Q512 548 574 530"/>
<path d="M446 562 Q512 582 578 562"/>
<path d="M448 594 Q512 614 576 594"/>
<path d="M454 626 Q512 644 570 626"/>
<path d="M512 505 L512 650"/>
<path d="M404 744 Q512 712 620 744"/>
</g>
</g>
</svg>''';

  /// The width and height of the emblem.
  final double size;

  @override
  Widget build(BuildContext context) {
    // 버튼색으로 그림과 테두리를, 화면 배경색으로 바탕을 칠한 SVG
    final svg = buildSvg(
      figureColor: context.accentColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
    // 고정 크기 SVG 그림
    return SvgPicture.string(svg, width: size, height: size);
  }

  /*──────────────────────────────────────────────────────────────────────
   Purpose  : Fills the emblem SVG template with the given colors.
   Author   : YUNDEOKSOO                        Created : 2026-11-05
  ──────────────────────────────────────────────────────────────────────*/
  /// Returns the emblem SVG drawn with [figureColor] on [backgroundColor].
  static String buildSvg({
    required Color figureColor,
    required Color backgroundColor,
  }) {
    // 두 자리 표시자를 #RRGGBB 색으로 바꾼다.
    return _svgTemplate
        .replaceAll(_figureColorToken, _toHex(figureColor))
        .replaceAll(_backgroundColorToken, _toHex(backgroundColor));
  }

  // 색을 SVG가 이해하는 #RRGGBB 문자열로 바꾼다(투명도는 버린다).
  static String _toHex(Color color) {
    // 32비트 ARGB 값에서 RGB 24비트만 남긴다.
    final rgb = color.toARGB32() & 0xFFFFFF;
    // 6자리 16진수로 만든다.
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}
