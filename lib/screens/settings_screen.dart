import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../controllers/counter_controller.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/accent_preset.dart';
import '../models/background_preset.dart';
import '../models/bell_sound.dart';
import '../models/calendar_target.dart';
import '../services/calendar_sync_service.dart';
import '../theme/app_colors.dart';
import '../widgets/color_swatch_option.dart';
import '../widgets/interval_slider.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Lets the user set the count interval, bell sound, colors, and calendar recording.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 카운트 간격·종소리·색상 테마(배경색·버튼색)·캘린더 기록 설정 화면.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({
    super.key,
    required this.counterController,
    required this.onIntervalChanged,
    required this.onBellSoundChanged,
    required this.appSettingsController,
    required this.calendarSyncService,
  });

  /// The counter whose interval is edited.
  final CounterController counterController;

  /// Applies and stores a new interval, in seconds.
  final ValueChanged<int> onIntervalChanged;

  /// Applies, previews, and stores a new bell sound.
  final ValueChanged<BellSound> onBellSoundChanged;

  /// Holds the theme and calendar settings.
  final AppSettingsController appSettingsController;

  /// Reads device calendars for the calendar picker.
  final CalendarSyncService calendarSyncService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// 캘린더 연결 진행 상태
class _SettingsScreenState extends State<SettingsScreen> {
  // 화면 여백
  static const double _screenPadding = 20;
  // 카드 안쪽 여백
  static const double _cardPadding = 20;
  // 카드 사이 간격
  static const double _cardSpacing = 12;
  // 제목과 내용 사이 간격
  static const double _titleSpacing = 12;
  // 색 견본 사이 간격
  static const double _swatchSpacing = 2;

  // 캘린더 목록을 불러오는 중인지 여부(중복 요청 방지)
  bool _isLoadingCalendars = false;

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 화면 뼈대
    return Scaffold(
      // "설정"
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      // 두 컨트롤러 중 하나라도 바뀌면 다시 그린다.
      body: ListenableBuilder(
        // 감시 대상
        listenable: Listenable.merge(<Listenable>[
          widget.counterController,
          widget.appSettingsController,
        ]),
        // 화면 내용
        builder: (context, _) => ListView(
          // 여백
          padding: const EdgeInsets.all(_screenPadding),
          children: <Widget>[
            // 카운트 간격
            _buildIntervalCard(localizations),
            // 간격
            const SizedBox(height: _cardSpacing),
            // 종소리
            _buildSoundCard(localizations),
            // 간격
            const SizedBox(height: _cardSpacing),
            // 테마
            _buildThemeCard(localizations),
            // 간격
            const SizedBox(height: _cardSpacing),
            // 캘린더 기록
            _buildCalendarCard(localizations),
          ],
        ),
      ),
    );
  }

  // 카운트 간격 카드
  Widget _buildIntervalCard(AppLocalizations localizations) {
    // 제목이 있는 카드
    return _buildSectionCard(
      // "카운트 간격"
      title: localizations.settingsIntervalSection,
      // 설명과 슬라이더
      children: <Widget>[
        // "자동 간격 방식에서 1배를 세는 간격입니다"
        Text(
          // 설명
          localizations.settingsIntervalDescription,
          // 보조 글자
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.textSecondaryColor),
        ),
        // 간격
        const SizedBox(height: _titleSpacing),
        // 값과 슬라이더(가운데)
        Center(
          // 슬라이더
          child: IntervalSlider(
            // 현재 간격
            seconds: widget.counterController.intervalSeconds,
            // 움직이면 바로 적용·저장한다.
            onChanged: widget.onIntervalChanged,
          ),
        ),
      ],
    );
  }

  // 종소리 선택 카드
  Widget _buildSoundCard(AppLocalizations localizations) {
    // 현재 종소리
    final selectedSound = widget.counterController.bellSound;
    // 제목이 있는 카드
    return _buildSectionCard(
      // "종소리"
      title: localizations.settingsSoundSection,
      children: <Widget>[
        // 설명
        Text(
          // "알림 방식이 종소리일 때 울리는 소리입니다…"
          localizations.settingsSoundDescription,
          // 보조 글자
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.textSecondaryColor),
        ),
        // 간격
        const SizedBox(height: _titleSpacing / 2),
        // 소리마다 한 줄
        for (final bellSound in BellSound.values)
          // 한 줄
          ListTile(
            // 좌우 여백 제거
            contentPadding: EdgeInsets.zero,
            // 재생 아이콘(누르면 들어 볼 수 있다는 표시)
            leading: Icon(
              Icons.play_circle_outline,
              color: context.textSecondaryColor,
            ),
            // 소리 이름
            title: Text(_soundNameOf(localizations, bellSound)),
            // 선택된 소리는 체크 표시
            trailing: bellSound == selectedSound
                ? Icon(Icons.check, color: context.accentColor)
                : null,
            // 누르면 고르고 바로 들려준다.
            onTap: () => widget.onBellSoundChanged(bellSound),
          ),
      ],
    );
  }

  // 종소리 이름
  String _soundNameOf(AppLocalizations localizations, BellSound bellSound) {
    // 소리별 번역 이름
    return switch (bellSound) {
      // 중저음 종
      BellSound.deep => localizations.soundDeep,
      // 맑은 종
      BellSound.clear => localizations.soundClear,
      // 풍경
      BellSound.chime => localizations.soundChime,
      // 목탁
      BellSound.moktak => localizations.soundMoktak,
    };
  }

  // 색상 테마 카드(배경색과 버튼색)
  Widget _buildThemeCard(AppLocalizations localizations) {
    // 현재 설정
    final settings = widget.appSettingsController.settings;
    // 제목이 있는 카드
    return _buildSectionCard(
      // "색상 테마"
      title: localizations.settingsThemeSection,
      children: <Widget>[
        // "배경색"
        _buildSubheading(localizations.themeBackgroundLabel),
        // 배경색 견본들
        Wrap(
          // 가로 간격
          spacing: _swatchSpacing,
          // 세로 간격
          runSpacing: _swatchSpacing,
          children: <Widget>[
            // 배경색 프리셋마다 견본
            for (final preset in BackgroundPreset.values)
              // 배경색 원 안에 카드색 원
              ColorSwatchOption(
                // 이름
                label: _backgroundNameOf(localizations, preset),
                // 배경색
                fillColor: SurfacePalette.of(preset).background,
                // 카드색
                innerColor: SurfacePalette.of(preset).card,
                // 얇은 테두리(흰 배경도 보이도록 바탕 면 색)
                borderColor: SurfacePalette.of(preset).track,
                // 선택 여부
                isSelected: preset == settings.backgroundPreset,
                // 누르면 바로 적용한다.
                onTap: () =>
                    widget.appSettingsController.setBackgroundPreset(preset),
              ),
          ],
        ),
        // 간격
        const SizedBox(height: _titleSpacing * 2),
        // "버튼색"
        _buildSubheading(localizations.themeAccentLabel),
        // 버튼색 견본들
        Wrap(
          // 가로 간격
          spacing: _swatchSpacing,
          // 세로 간격
          runSpacing: _swatchSpacing,
          children: <Widget>[
            // 버튼색 프리셋마다 견본
            for (final preset in AccentPreset.values)
              // 버튼색 원
              ColorSwatchOption(
                // 이름
                label: _accentNameOf(localizations, preset),
                // 버튼색
                fillColor: AccentPalette.of(preset).accent,
                // 테두리는 버튼색과 같게
                borderColor: AccentPalette.of(preset).accent,
                // 선택 여부
                isSelected: preset == settings.accentPreset,
                // 누르면 바로 적용한다.
                onTap: () =>
                    widget.appSettingsController.setAccentPreset(preset),
              ),
          ],
        ),
      ],
    );
  }

  // 카드 안의 작은 소제목
  Widget _buildSubheading(String text) {
    // 아래 여백을 둔 소제목
    return Padding(
      // 아래 간격
      padding: const EdgeInsets.only(bottom: _titleSpacing),
      // 보조 글자
      child: Text(
        // 소제목
        text,
        // 보조 색 글자
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: context.textSecondaryColor),
      ),
    );
  }

  // 캘린더 기록 카드
  Widget _buildCalendarCard(AppLocalizations localizations) {
    // 현재 설정
    final settings = widget.appSettingsController.settings;
    // 선택된 캘린더
    final calendarTarget = settings.calendarTarget;
    // 제목이 있는 카드
    return _buildSectionCard(
      // "캘린더 기록"
      title: localizations.settingsCalendarSection,
      children: <Widget>[
        // 켜기/끄기 스위치
        SwitchListTile(
          // 좌우 여백 제거
          contentPadding: EdgeInsets.zero,
          // 켜짐 여부(캘린더가 정해져 있어야 켜진 것으로 본다)
          value: settings.shouldWriteToCalendar,
          // 목록을 불러오는 중에는 비활성
          onChanged: _isLoadingCalendars ? null : _handleCalendarSwitch,
          // "수행 기록을 캘린더에 추가"
          title: Text(localizations.calendarSyncTitle),
          // 설명
          subtitle: Text(localizations.calendarSyncDescription),
        ),
        // 켜져 있으면 기록할 캘린더를 보여 주고 바꿀 수 있게 한다.
        if (settings.shouldWriteToCalendar)
          // 캘린더 선택 줄
          ListTile(
            // 좌우 여백 제거
            contentPadding: EdgeInsets.zero,
            // 달력 아이콘
            leading: Icon(Icons.event_available, color: context.accentColor),
            // "기록할 캘린더"
            title: Text(localizations.calendarTargetLabel),
            // 캘린더 이름(계정)
            subtitle: Text(
              calendarTarget == null
                  ? localizations.calendarNotSelected
                  : _describeCalendar(calendarTarget),
            ),
            // 바꾸기 화살표
            trailing: const Icon(Icons.chevron_right),
            // 누르면 다시 고른다.
            onTap: _isLoadingCalendars ? null : _pickCalendar,
          ),
        // 불러오는 중 표시
        if (_isLoadingCalendars) const LinearProgressIndicator(),
      ],
    );
  }

  // 제목과 내용을 가진 카드
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    // 카드
    return Card(
      // 안쪽 여백
      child: Padding(
        // 여백
        padding: const EdgeInsets.all(_cardPadding),
        // 세로로 쌓는다.
        child: Column(
          // 왼쪽 정렬
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 카드 제목
            Text(
              // 제목 문구
              title,
              // 굵은 제목 글자
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            // 간격
            const SizedBox(height: _titleSpacing),
            // 내용
            ...children,
          ],
        ),
      ),
    );
  }

  // 배경색 이름
  String _backgroundNameOf(
    AppLocalizations localizations,
    BackgroundPreset preset,
  ) {
    // 프리셋별 번역 이름
    return switch (preset) {
      // 검정
      BackgroundPreset.black => localizations.themeBlack,
      // 차콜
      BackgroundPreset.charcoal => localizations.themeCharcoal,
      // 다크 그레이
      BackgroundPreset.darkGray => localizations.themeDarkGray,
      // 웜 브라운
      BackgroundPreset.warmBrown => localizations.themeWarmBrown,
      // 네이비
      BackgroundPreset.navy => localizations.themeNavy,
      // 화이트
      BackgroundPreset.white => localizations.themeWhite,
      // 라이트 그레이
      BackgroundPreset.lightGray => localizations.themeLightGray,
    };
  }

  // 버튼색 이름
  String _accentNameOf(AppLocalizations localizations, AccentPreset preset) {
    // 프리셋별 번역 이름
    return switch (preset) {
      // 금빛
      AccentPreset.gold => localizations.accentGold,
      // 블루
      AccentPreset.blue => localizations.accentBlue,
      // 딥 블루
      AccentPreset.deepBlue => localizations.accentDeepBlue,
      // 그레이
      AccentPreset.gray => localizations.accentGray,
    };
  }

  // "캘린더 이름 (계정)" 문구
  String _describeCalendar(CalendarTarget calendarTarget) {
    // 계정 이름이 없으면 캘린더 이름만 보여 준다.
    if (calendarTarget.accountName.isEmpty) {
      // 이름만
      return calendarTarget.name;
    }
    // 이름과 계정을 함께 보여 준다.
    return '${calendarTarget.name} (${calendarTarget.accountName})';
  }

  // 스위치: 켜면 캘린더를 고르고, 끄면 기록을 멈춘다.
  Future<void> _handleCalendarSwitch(bool isEnabled) async {
    // 끄는 경우
    if (!isEnabled) {
      // 기록을 멈춘다.
      widget.appSettingsController.disableCalendarSync();
      // 처리 끝
      return;
    }
    // 켜는 경우 캘린더를 고른다.
    await _pickCalendar();
  }

  // 권한을 받고 캘린더 목록에서 하나를 고르게 한다.
  Future<void> _pickCalendar() async {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 하단 안내 도구
    final messenger = ScaffoldMessenger.of(context);
    // 불러오는 중으로 표시한다.
    setState(() => _isLoadingCalendars = true);
    // 캘린더 목록
    List<CalendarTarget> calendars;
    // 권한 거부나 플랫폼 오류가 날 수 있다.
    try {
      // 쓰기 가능한 캘린더를 불러온다.
      calendars = await widget.calendarSyncService.loadWritableCalendars();
    } on CalendarSyncException catch (error) {
      // 실패 원인을 남긴다.
      debugPrint('[SettingsScreen] 캘린더 목록 실패: $error');
      // 화면이 사라졌으면 끝낸다.
      if (!mounted) {
        // 처리 끝
        return;
      }
      // 불러오기 종료
      setState(() => _isLoadingCalendars = false);
      // 권한 거부와 그 외 오류를 나눠 안내한다.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.failure == CalendarSyncFailure.permissionDenied
                ? localizations.calendarPermissionDenied
                : localizations.calendarLoadFailed,
          ),
        ),
      );
      // 처리 끝
      return;
    }
    // 화면이 사라졌으면 끝낸다.
    if (!mounted) {
      // 처리 끝
      return;
    }
    // 불러오기 종료
    setState(() => _isLoadingCalendars = false);
    // 쓸 수 있는 캘린더가 없으면 안내한다.
    if (calendars.isEmpty) {
      // "쓸 수 있는 캘린더가 없습니다..."
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.calendarEmpty)),
      );
      // 처리 끝
      return;
    }
    // 목록 대화상자를 띄워 하나를 고르게 한다.
    final selectedCalendar = await showDialog<CalendarTarget>(
      // 현재 화면 문맥
      context: context,
      // 대화상자 내용
      builder: (dialogContext) => SimpleDialog(
        // "캘린더 선택"
        title: Text(localizations.calendarPickerTitle),
        // 캘린더마다 한 줄
        children: <Widget>[
          // 각 캘린더
          for (final calendar in calendars)
            // 한 줄
            SimpleDialogOption(
              // 누르면 그 캘린더로 닫는다.
              onPressed: () => Navigator.of(dialogContext).pop(calendar),
              // 이름과 계정
              child: ListTile(
                // 좌우 여백 제거
                contentPadding: EdgeInsets.zero,
                // 캘린더 이름
                title: Text(calendar.name),
                // 계정 이름(있을 때만)
                subtitle: calendar.accountName.isEmpty
                    ? null
                    : Text(calendar.accountName),
              ),
            ),
        ],
      ),
    );
    // 고르지 않았으면 그대로 둔다.
    if (selectedCalendar == null) {
      // 처리 끝
      return;
    }
    // 고른 캘린더로 기록을 켠다.
    widget.appSettingsController.enableCalendarSync(selectedCalendar);
  }
}
