import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/alert_mode.dart';
import '../models/bell_sound.dart';
import '../theme/app_colors.dart';
import 'display_formats.dart';
import 'setting_labels.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the current interval and alert setting in one tappable line.
 Remarks  : The values are changed only on the settings screen.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 메인 화면의 "절 간격 10초 | 알림 종소리 · 중저음 종 ›" 한 줄 요약.
class SettingsSummaryBar extends StatelessWidget {
  /// Creates the summary line.
  const SettingsSummaryBar({
    super.key,
    required this.intervalSeconds,
    required this.alertMode,
    required this.bellSound,
    required this.onTap,
  });

  // 안쪽 가로 여백
  static const double _horizontalPadding = 14;
  // 안쪽 세로 여백
  static const double _verticalPadding = 12;
  // 항목 사이 간격
  static const double _itemSpacing = 10;
  // 이름과 값 사이 간격
  static const double _labelSpacing = 4;
  // 모서리 반지름
  static const double _cornerRadius = 14;

  /// The automatic interval, in seconds.
  final int intervalSeconds;

  /// The per-bow feedback.
  final AlertMode alertMode;

  /// The bell sound, shown only when [alertMode] is bell.
  final BellSound bellSound;

  /// Called when the line is tapped, usually to open the settings screen.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 글자 스타일
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    // 이름 글자 스타일(보조 색)
    final labelStyle = textStyle?.copyWith(color: context.textSecondaryColor);
    // 카드 모양 버튼
    return Material(
      // 카드 색
      color: Theme.of(context).colorScheme.surfaceContainer,
      // 둥근 모서리
      borderRadius: BorderRadius.circular(_cornerRadius),
      // 눌림 효과
      child: InkWell(
        // 누르면 설정
        onTap: onTap,
        // 눌림 효과 모서리
        borderRadius: BorderRadius.circular(_cornerRadius),
        // 안쪽 여백
        child: Padding(
          // 여백
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          // 한 줄 배치
          child: Row(
            children: <Widget>[
              // "절 간격"
              Text(localizations.summaryIntervalLabel, style: labelStyle),
              // 간격
              const SizedBox(width: _labelSpacing),
              // "10초"
              Text(
                DisplayFormatter(localizations)
                    .formatDuration(Duration(seconds: intervalSeconds)),
                style: textStyle,
              ),
              // 간격
              const SizedBox(width: _itemSpacing),
              // 구분선
              Text('|', style: labelStyle),
              // 간격
              const SizedBox(width: _itemSpacing),
              // "알림"
              Text(localizations.summaryAlertLabel, style: labelStyle),
              // 간격
              const SizedBox(width: _labelSpacing),
              // "종소리 · 중저음 종"(길면 말줄임)
              Expanded(
                child: Text(
                  _alertText(localizations),
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 설정으로 간다는 화살표
              Icon(Icons.chevron_right, color: context.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  // 알림 값 문구: 종소리면 소리 종류까지, 아니면 방식만
  String _alertText(AppLocalizations localizations) {
    // 알림 방식 이름
    final modeName = SettingLabels.alertModeName(localizations, alertMode);
    // 종소리가 아니면 방식 이름만 쓴다.
    if (alertMode != AlertMode.bell) {
      // "진동" 또는 "무음"
      return modeName;
    }
    // "종소리 · 중저음 종"
    return localizations.summaryBellValue(
      modeName,
      SettingLabels.bellSoundName(localizations, bellSound),
    );
  }
}
