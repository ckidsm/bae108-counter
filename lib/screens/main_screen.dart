import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../controllers/counter_controller.dart';
import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/counter_phase.dart';
import '../services/bow_feedback_service.dart';
import '../services/calendar_sync_service.dart';
import '../services/practice_record_repository.dart';
import '../services/practice_statistics_calculator.dart';
import '../services/wake_lock_service.dart';
import '../services/watch_sync_service.dart';
import '../theme/app_colors.dart';
import '../theme/screen_layout.dart';
import '../widgets/ascetic_emblem.dart';
import '../widgets/clock_header.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_ring.dart';
import '../widgets/guide_message.dart';
import '../widgets/practice_overview_panel.dart';
import '../widgets/segment_progress_bars.dart';
import '../widgets/settings_summary_bar.dart';
import '../widgets/today_progress_card.dart';
import 'completion_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the counter, its options, and the controls of today's practice.
 Remarks  : Opens the completion screen shortly after the 108th bow so the green
            completed ring is visible first.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// "오늘의 108배" 메인 화면.
class MainScreen extends StatefulWidget {
  /// Creates the main screen with its services.
  const MainScreen({
    super.key,
    required this.repository,
    required this.feedbackService,
    required this.wakeLockService,
    required this.appSettingsController,
    required this.calendarSyncService,
    this.watchSyncService = const NoopWatchSyncService(),
  });

  /// Stores practice records and settings.
  final PracticeRecordRepository repository;

  /// Plays the per-bow feedback.
  final BowFeedbackService feedbackService;

  /// Keeps the screen on during a practice.
  final WakeLockService wakeLockService;

  /// Holds the theme and calendar settings.
  final AppSettingsController appSettingsController;

  /// Adds saved records to the device calendar.
  final CalendarSyncService calendarSyncService;

  /// Syncs settings and records with the Apple Watch app.
  final WatchSyncService watchSyncService;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// 메인 화면 상태(컨트롤러 보관)
class _MainScreenState extends State<MainScreen> {
  // 완료 후 회향 화면을 열기까지 기다리는 시간(녹색 링을 먼저 보여 주기 위함)
  static const Duration _completionScreenDelay = Duration(milliseconds: 1500);
  // 화면 좌우 여백
  static const double _horizontalPadding = 20;
  // 화면 위아래 여백
  static const double _verticalPadding = 12;
  // 작은 간격
  static const double _smallSpacing = 8;
  // 보통 간격
  static const double _mediumSpacing = 16;
  // 큰 간격
  static const double _largeSpacing = 24;
  // 태블릿 좌우 여백
  static const double _tabletHorizontalPadding = 36;
  // 태블릿 양쪽 열 최대 폭
  static const double _tabletSideMaxWidth = 300;
  // 태블릿 양쪽 열 최소 폭
  static const double _tabletSideMinWidth = 240;
  // 화면 폭 대비 태블릿 양쪽 열 폭 비율
  static const double _tabletSideWidthRatio = 0.25;
  // 태블릿 열 사이 간격
  static const double _tabletColumnSpacing = 28;
  // 화면 켜짐 안내 아이콘 크기
  static const double _noticeIconSize = 16;

  // 카운터 로직
  late final CounterController _controller;
  // 직전 단계(완료로 바뀌는 순간을 알기 위함)
  CounterPhase _previousPhase = CounterPhase.idle;
  // 워치 기록 도착 알림 구독
  StreamSubscription<void>? _watchSubscription;
  // 회향 화면이 열려 있는지 여부(중복으로 열지 않기 위함)
  bool _isCompletionScreenOpen = false;

  @override
  void initState() {
    // 부모 초기화를 먼저 한다.
    super.initState();
    // 저장된 설정으로 컨트롤러를 만든다.
    _controller = CounterController(
      // 알림 서비스
      feedbackService: widget.feedbackService,
      // 화면 켜짐 서비스
      wakeLockService: widget.wakeLockService,
      // 지난번 설정(없으면 기본값)
      settings: widget.repository.loadSettings(CounterRules.defaultSettings),
    );
    // 단계 변화를 감시한다.
    _controller.addListener(_handleControllerChanged);
    // 워치에 현재 설정을 보낸다.
    unawaited(widget.watchSyncService.sendSettings(_controller.settings));
    // 워치에서 새 기록이 도착하면 가져온다.
    _watchSubscription = widget.watchSyncService.sessionsAvailable.listen(
      (_) => unawaited(_importWatchSessions()),
    );
    // 앱이 꺼져 있는 동안 쌓인 워치 기록도 가져온다.
    unawaited(_importWatchSessions());
  }

  @override
  void dispose() {
    // 워치 기록 도착 감시를 해제한다.
    unawaited(_watchSubscription?.cancel());
    // 감시를 해제한다.
    _controller.removeListener(_handleControllerChanged);
    // 컨트롤러를 정리한다(타이머·화면 켜짐 해제).
    _controller.dispose();
    // 부모 정리를 이어서 한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 화면 뼈대
    return Scaffold(
      // 노치·상태바를 피한다.
      body: SafeArea(
        // 컨트롤러가 바뀔 때마다 다시 그린다.
        child: ListenableBuilder(
          // 감시 대상
          listenable: _controller,
          // 화면 내용
          // 넓은 가로 화면(태블릿)이면 3단, 아니면 휴대폰 화면
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) =>
                ScreenLayout.useWideLayout(constraints.biggest)
                ? _buildTabletLayout(localizations, constraints.maxWidth)
                : _buildPhoneLayout(localizations),
          ),
        ),
      ),
    );
  }

  // 휴대폰(세로): 위에서 아래로 한 화면
  Widget _buildPhoneLayout(AppLocalizations localizations) {
    // 여백
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      // 스크롤 없이 한 화면에 위에서 아래로 놓는다.
      child: Column(
        // 왼쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 시계와 기록·설정 버튼
          _buildHeader(localizations),
          // 간격
          const SizedBox(height: _smallSpacing),
          // 엠블럼과 제목·화면 켜짐 안내
          _buildTitle(localizations),
          // 간격
          const SizedBox(height: _mediumSpacing),
          // 절 간격·알림 요약(누르면 설정)
          _buildSummaryBar(isStacked: false),
          // 원형 카운터·구간 막대·안내 문구가 남은 높이를 차지한다.
          Expanded(child: _buildCounterArea(localizations)),
          // 하단 버튼(화면 아래 고정)
          _buildControls(isVertical: false),
        ],
      ),
    );
  }

  // 태블릿(가로): 오늘 현황 | 원형 카운터 | 설정·버튼 3단
  Widget _buildTabletLayout(
    AppLocalizations localizations,
    double screenWidth,
  ) {
    // 양쪽 열 폭: 좁은 태블릿에서는 줄여 가운데 원을 크게 남긴다.
    final sideWidth = (screenWidth * _tabletSideWidthRatio).clamp(
      _tabletSideMinWidth,
      _tabletSideMaxWidth,
    );
    // 오늘 날짜
    final today = DateTime.now();
    // 연속 수행·이번 주 통계
    final statistics = PracticeStatisticsCalculator.calculate(
      widget.repository.loadSessions(),
      today,
    );
    // 여백
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _tabletHorizontalPadding,
        vertical: _verticalPadding * 2,
      ),
      child: Column(
        children: <Widget>[
          // 시계와 기록·설정 버튼
          _buildHeader(localizations),
          // 간격
          const SizedBox(height: _mediumSpacing),
          // 3단이 남은 높이를 차지한다.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 왼쪽: 엠블럼·제목, 연속 수행, 이번 주
                SizedBox(
                  width: sideWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 엠블럼과 제목
                      _buildTitle(localizations),
                      // 간격
                      const SizedBox(height: _largeSpacing),
                      // 연속 수행·이번 주
                      PracticeOverviewPanel(
                        statistics: statistics,
                        today: today,
                      ),
                    ],
                  ),
                ),
                // 간격
                const SizedBox(width: _tabletColumnSpacing),
                // 가운데: 원형 카운터·구간 막대·안내
                Expanded(child: _buildCounterArea(localizations)),
                // 간격
                const SizedBox(width: _tabletColumnSpacing),
                // 오른쪽: 설정 요약, 오늘 진행, 세로 버튼
                SizedBox(
                  width: sideWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 절 간격·알림 요약(두 줄)
                      _buildSummaryBar(isStacked: true),
                      // 간격
                      const SizedBox(height: _mediumSpacing),
                      // 오늘 진행
                      TodayProgressCard(
                        startedAt: _controller.startedAt,
                        activeElapsed: _controller.activeElapsed,
                        count: _controller.count,
                      ),
                      // 버튼을 아래로 민다.
                      const Spacer(),
                      // 세로 버튼
                      _buildControls(isVertical: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 절 간격·알림 요약(누르면 설정)
  Widget _buildSummaryBar({required bool isStacked}) {
    // 요약 바
    return SettingsSummaryBar(
      // 절 간격(초)
      intervalSeconds: _controller.intervalSeconds,
      // 알림 방식
      alertMode: _controller.alertMode,
      // 종소리 종류
      bellSound: _controller.bellSound,
      // 누르면 설정 화면을 연다.
      onTap: _openSettings,
      // 두 줄 여부
      isStacked: isStacked,
    );
  }

  // 시작 | 정지 | 처음부터
  Widget _buildControls({required bool isVertical}) {
    // 버튼 줄
    return CounterControls(
      // 현재 단계
      phase: _controller.phase,
      // 현재 절 수
      count: _controller.count,
      // 시작(완료 후에는 회향하기)
      onStart: _handleStartPressed,
      // 정지(센 수 유지)
      onStop: _controller.stop,
      // 처음부터
      onReset: _confirmReset,
      // 세로 배치 여부
      isVertical: isVertical,
    );
  }

  // 시계와 기록 화면 버튼 줄
  Widget _buildHeader(AppLocalizations localizations) {
    // 양 끝 정렬
    return Row(
      children: <Widget>[
        // 시계가 남은 폭을 차지한다.
        const Expanded(child: ClockHeader()),
        // 기록 화면 버튼
        IconButton(
          // 설명
          tooltip: localizations.historyTooltip,
          // 달력 아이콘
          icon: const Icon(Icons.calendar_month_outlined),
          // 누르면 기록 화면을 연다.
          onPressed: _openHistory,
        ),
        // 설정 화면 버튼(달력 오른쪽)
        IconButton(
          // 설명
          tooltip: localizations.settingsTooltip,
          // 톱니바퀴 아이콘
          icon: const Icon(Icons.settings_outlined),
          // 누르면 설정 화면을 연다.
          onPressed: _openSettings,
        ),
      ],
    );
  }

  // 고행상 엠블럼과 제목·화면 켜짐 안내
  Widget _buildTitle(AppLocalizations localizations) {
    // 엠블럼을 왼쪽에, 제목 묶음을 오른쪽에 둔다.
    return Row(
      children: <Widget>[
        // 고행상 엠블럼
        const AsceticEmblem(),
        // 간격
        const SizedBox(width: _mediumSpacing),
        // 제목 묶음이 남은 폭을 차지한다.
        Expanded(child: _buildTitleText(localizations)),
      ],
    );
  }

  // 제목과 화면 켜짐 안내
  Widget _buildTitleText(AppLocalizations localizations) {
    // 글자 스타일
    final textTheme = Theme.of(context).textTheme;
    // 세로로 쌓는다.
    return Column(
      // 왼쪽 정렬
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // "오늘의 108배"
        Text(
          // 제목
          localizations.mainTitle,
          // 굵은 큰 글자
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        // 간격
        const SizedBox(height: _smallSpacing / 2),
        // 화면 켜짐 안내 줄
        Row(
          children: <Widget>[
            // 해 아이콘
            Icon(
              Icons.light_mode_outlined,
              size: _noticeIconSize,
              color: context.accentColor,
            ),
            // 간격
            const SizedBox(width: _smallSpacing / 2),
            // "108배까지 화면 켜짐 유지"(번역이 길면 줄바꿈되도록 남은 폭만 쓴다)
            Flexible(
              // 안내 문구
              child: Text(
                // 문구
                localizations.keepScreenOnNotice,
                // 버튼색 작은 글자
                style: textTheme.bodySmall?.copyWith(
                  color: context.accentColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 원형 카운터, 27배 구간 막대, 안내 문구(남은 높이 안에서 가운데 정렬)
  Widget _buildCounterArea(AppLocalizations localizations) {
    // 세로 가운데 정렬
    return Column(
      // 세로 가운데
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // 원은 남은 높이에 맞춰 줄어들 수 있다.
        Flexible(child: _buildCounterRing(localizations)),
        // 간격
        const SizedBox(height: _largeSpacing),
        // 27배 구간 막대
        SegmentProgressBars(
          // 현재 절 수
          count: _controller.count,
          // 완료 여부
          isCompleted: _controller.isCompleted,
        ),
        // 간격
        const SizedBox(height: _mediumSpacing),
        // 안내 문구
        GuideMessage(controller: _controller),
        // 버튼과의 간격
        const SizedBox(height: _largeSpacing),
      ],
    );
  }

  // 원형 카운터
  Widget _buildCounterRing(AppLocalizations localizations) {
    // 준비 중인지 여부
    final isPreparing = _controller.phase == CounterPhase.preparing;
    // 원형 카운터를 만든다.
    return CounterRing(
      // 전체 진행률
      progress: _controller.progress,
      // 안쪽 링 진행률
      innerProgress: _controller.innerRingProgress,
      // 완료 여부
      isCompleted: _controller.isCompleted,
      // 준비 중이면 남은 준비 초, 아니면 현재 절 수
      valueText: isPreparing
          ? '${_controller.preparationRemainingSeconds}'
          : '${_controller.count}',
      // 준비 중이면 "준비", 아니면 "/ 108"
      captionText: isPreparing
          ? localizations.preparationLabel
          : localizations.counterTarget(CounterRules.targetBowCount),
    );
  }

  // 컨트롤러 값을 바꾼 뒤 설정을 저장한다.
  void _updateSettings(VoidCallback change) {
    // 값을 바꾼다.
    change();
    // 바뀐 설정을 저장한다(완료를 기다리지 않는다).
    unawaited(widget.repository.saveSettings(_controller.settings));
    // 워치도 같은 간격으로 세도록 보낸다.
    unawaited(widget.watchSyncService.sendSettings(_controller.settings));
  }

  // 워치에서 끝낸 수행 기록을 가져와 아직 없는 것만 저장한다.
  Future<void> _importWatchSessions() async {
    // 워치 기록을 가져온다.
    final watchSessions = await widget.watchSyncService.takeCompletedSessions();
    // 없으면 끝낸다.
    if (watchSessions.isEmpty) {
      // 처리 끝
      return;
    }
    // 이미 저장된 기록 식별자
    final savedIds = widget.repository
        .loadSessions()
        .map((session) => session.id)
        .toSet();
    // 새로 저장한 개수
    var importedCount = 0;
    // 아직 없는 기록만 저장한다(같은 기록이 두 번 와도 한 번만 저장).
    for (final session in watchSessions) {
      // 이미 있으면 건너뛴다.
      if (!savedIds.add(session.id)) {
        // 중복
        continue;
      }
      // 저장은 실패할 수 있다.
      try {
        // 기록을 저장한다.
        await widget.repository.addSession(session);
        // 개수를 센다.
        importedCount++;
      } on StateError catch (error) {
        // 실패한 기록을 남긴다.
        debugPrint('[MainScreen] 워치 기록 저장 실패 ${session.id}: $error');
      }
    }
    // 저장한 것이 없거나 화면이 사라졌으면 끝낸다.
    if (importedCount == 0 || !mounted) {
      // 처리 끝
      return;
    }
    // "Apple Watch 수행 기록 N건을 저장했습니다"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).watchSessionsImported(importedCount),
        ),
      ),
    );
  }

  // 단계가 완료로 바뀌면 잠시 후 회향 화면을 연다.
  void _handleControllerChanged() {
    // 이번에 처음 완료가 되었는지 확인한다.
    final didJustComplete =
        _previousPhase != CounterPhase.completed && _controller.isCompleted;
    // 다음 비교를 위해 현재 단계를 기억한다.
    _previousPhase = _controller.phase;
    // 방금 완료된 것이 아니면 끝낸다.
    if (!didJustComplete) {
      // 할 일 없음
      return;
    }
    // 녹색 링을 잠깐 보여 준 뒤 회향 화면을 연다.
    unawaited(
      Future<void>.delayed(_completionScreenDelay, () {
        // 그 사이 화면이 닫혔거나 처음부터를 눌러 완료 상태가 아니면 열지 않는다.
        if (!mounted || !_controller.isCompleted) {
          // 열지 않음
          return;
        }
        // 회향 화면을 연다.
        unawaited(_openCompletion());
      }),
    );
  }

  // 시작 버튼: 완료면 회향 화면, 아니면 시작(정지 후에는 이어서)
  void _handleStartPressed() {
    // 완료 상태면 회향 화면을 다시 연다.
    if (_controller.isCompleted) {
      // 회향 화면 열기
      unawaited(_openCompletion());
      // 처리 끝
      return;
    }
    // 시작 또는 이어서
    _controller.start();
  }

  // 회향 화면을 열고 결과에 따라 카운터를 초기화한다.
  Future<void> _openCompletion() async {
    // 완료 기록을 만든다.
    final session = _controller.buildCompletedSession();
    // 이미 열려 있거나 기록이 없으면 열지 않는다.
    if (_isCompletionScreenOpen || session == null) {
      // 열지 않음
      return;
    }
    // 열린 상태로 표시한다.
    _isCompletionScreenOpen = true;
    // 회향 화면을 열고 결과를 기다린다.
    final outcome = await Navigator.of(context).push<CompletionOutcome>(
      // 화면 전환
      MaterialPageRoute<CompletionOutcome>(
        // 회향 화면
        builder: (_) => CompletionScreen(
          // 완료 기록
          session: session,
          // 저장소
          repository: widget.repository,
          // 캘린더 기록 설정
          appSettings: widget.appSettingsController.settings,
          // 캘린더 서비스
          calendarSyncService: widget.calendarSyncService,
        ),
      ),
    );
    // 닫힌 상태로 표시한다.
    _isCompletionScreenOpen = false;
    // 화면이 사라졌거나 뒤로 가기로 닫았으면 그대로 둔다.
    if (!mounted || outcome == null) {
      // 완료 상태 유지
      return;
    }
    // 저장했거나 한 번 더 하기를 골랐으면 처음부터 시작할 수 있게 초기화한다.
    _controller.reset();
    // 결과에 맞는 저장 안내 문구(다시 시작이면 없음)
    final savedMessage = _savedMessageOf(AppLocalizations.of(context), outcome);
    // 저장한 경우 알림을 띄운다.
    if (savedMessage != null) {
      // 하단 안내
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(savedMessage)));
    }
  }

  // 회향 화면 결과별 안내 문구
  String? _savedMessageOf(
    AppLocalizations localizations,
    CompletionOutcome outcome,
  ) {
    // 결과에 따라 문구를 고른다.
    return switch (outcome) {
      // 기록만 저장
      CompletionOutcome.saved => localizations.recordSaved,
      // 기록 저장 + 캘린더 추가
      CompletionOutcome.savedToCalendar => localizations.recordSavedToCalendar,
      // 기록은 저장, 캘린더 실패
      CompletionOutcome.savedCalendarFailed =>
        localizations.recordSavedCalendarFailed,
      // 다시 시작(안내 없음)
      CompletionOutcome.restarted => null,
    };
  }

  // 간격을 바꾸고 저장한다(설정 화면에서 호출).
  void _changeIntervalSeconds(int seconds) {
    // 간격을 바꾸고 설정을 저장한다.
    _updateSettings(() => _controller.setIntervalSeconds(seconds));
  }

  // 설정 화면을 연다.
  void _openSettings() {
    // 설정 화면으로 이동한다.
    unawaited(
      Navigator.of(context).push<void>(
        // 화면 전환
        MaterialPageRoute<void>(
          // 설정 화면
          builder: (_) => SettingsScreen(
            // 카운터(간격 표시용)
            counterController: _controller,
            // 간격 변경·저장
            onIntervalChanged: _changeIntervalSeconds,
            // 종소리 변경·미리 듣기·저장
            onBellSoundChanged: (bellSound) =>
                _updateSettings(() => _controller.setBellSound(bellSound)),
            // 알림 방식 변경·저장
            onAlertModeChanged: (alertMode) =>
                _updateSettings(() => _controller.setAlertMode(alertMode)),
            // 테마·캘린더 설정
            appSettingsController: widget.appSettingsController,
            // 캘린더 서비스
            calendarSyncService: widget.calendarSyncService,
          ),
        ),
      ),
    );
  }

  // 처음부터: 센 절이 있으면 확인 후 초기화한다.
  Future<void> _confirmReset() async {
    // 완료 상태이거나 센 절이 없으면 바로 초기화한다.
    if (_controller.isCompleted || _controller.count == 0) {
      // 초기화
      _controller.reset();
      // 처리 끝
      return;
    }
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 확인 대화상자를 띄운다.
    final isConfirmed = await showDialog<bool>(
      // 현재 화면 문맥
      context: context,
      // 대화상자 내용
      builder: (dialogContext) => AlertDialog(
        // "처음부터 다시 할까요?"
        title: Text(localizations.resetConfirmTitle),
        // "지금까지 센 N배가 사라집니다."
        content: Text(localizations.resetConfirmMessage(_controller.count)),
        // 버튼
        actions: <Widget>[
          // 취소
          TextButton(
            // false로 닫는다.
            onPressed: () => Navigator.of(dialogContext).pop(false),
            // "취소"
            child: Text(localizations.dialogCancel),
          ),
          // 확인
          FilledButton(
            // true로 닫는다.
            onPressed: () => Navigator.of(dialogContext).pop(true),
            // "확인"
            child: Text(localizations.dialogConfirm),
          ),
        ],
      ),
    );
    // 확인했고 화면이 아직 있으면 초기화한다.
    if (isConfirmed == true && mounted) {
      // 초기화
      _controller.reset();
    }
  }

  // 수행 기록 화면을 연다.
  void _openHistory() {
    // 기록 화면으로 이동한다.
    unawaited(
      Navigator.of(context).push<void>(
        // 화면 전환
        MaterialPageRoute<void>(
          // 기록 화면
          builder: (_) => HistoryScreen(repository: widget.repository),
        ),
      ),
    );
  }
}
