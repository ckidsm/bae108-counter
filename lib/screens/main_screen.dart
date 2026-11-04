import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/counter_controller.dart';
import '../controllers/counter_rules.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/count_mode.dart';
import '../models/counter_phase.dart';
import '../services/bow_feedback_service.dart';
import '../services/practice_record_repository.dart';
import '../services/wake_lock_service.dart';
import '../theme/app_colors.dart';
import '../widgets/alert_mode_selector.dart';
import '../widgets/clock_header.dart';
import '../widgets/count_mode_selector.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_ring.dart';
import '../widgets/guide_message.dart';
import '../widgets/interval_selector.dart';
import '../widgets/section_label.dart';
import '../widgets/segment_progress_bars.dart';
import 'completion_screen.dart';
import 'history_screen.dart';

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
  });

  /// Stores practice records and settings.
  final PracticeRecordRepository repository;

  /// Plays the per-bow feedback.
  final BowFeedbackService feedbackService;

  /// Keeps the screen on during a practice.
  final WakeLockService wakeLockService;

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
  // 화면 켜짐 안내 아이콘 크기
  static const double _noticeIconSize = 16;

  // 카운터 로직
  late final CounterController _controller;
  // 직전 단계(완료로 바뀌는 순간을 알기 위함)
  CounterPhase _previousPhase = CounterPhase.idle;
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
  }

  @override
  void dispose() {
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
          builder: (context, _) => SingleChildScrollView(
            // 여백
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _verticalPadding,
            ),
            // 위에서 아래로 쌓는다.
            child: Column(
              // 왼쪽 정렬
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 시계와 기록 버튼
                _buildHeader(localizations),
                // 간격
                const SizedBox(height: _smallSpacing),
                // 제목과 화면 켜짐 안내
                _buildTitle(localizations),
                // 간격
                const SizedBox(height: _largeSpacing),
                // 카운트 방식과 간격
                _buildCountOptions(localizations),
                // 간격
                const SizedBox(height: _largeSpacing),
                // 원형 카운터
                _buildCounterRing(localizations),
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
                // 안내 문구(가운데)
                Center(child: GuideMessage(controller: _controller)),
                // 간격
                const SizedBox(height: _largeSpacing),
                // 알림 방식 제목
                SectionLabel(localizations.alertModeTitle),
                // 알림 방식 선택
                AlertModeSelector(
                  // 현재 알림 방식
                  selectedMode: _controller.alertMode,
                  // 바꾸면 저장한다.
                  onChanged: (alertMode) => _updateSettings(
                    () => _controller.setAlertMode(alertMode),
                  ),
                ),
                // 간격
                const SizedBox(height: _largeSpacing),
                // 하단 버튼
                CounterControls(
                  // 현재 단계
                  phase: _controller.phase,
                  // 현재 절 수
                  count: _controller.count,
                  // 시작/일시정지/회향
                  onPrimaryPressed: _handlePrimaryPressed,
                  // 처음부터
                  onReset: _confirmReset,
                ),
              ],
            ),
          ),
        ),
      ),
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
      ],
    );
  }

  // 제목과 화면 켜짐 안내
  Widget _buildTitle(AppLocalizations localizations) {
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
            const Icon(
              Icons.light_mode_outlined,
              size: _noticeIconSize,
              color: AppColors.gold,
            ),
            // 간격
            const SizedBox(width: _smallSpacing / 2),
            // "108배까지 화면 켜짐 유지"(번역이 길면 줄바꿈되도록 남은 폭만 쓴다)
            Flexible(
              // 안내 문구
              child: Text(
                // 문구
                localizations.keepScreenOnNotice,
                // 금빛 작은 글자
                style: textTheme.bodySmall?.copyWith(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 카운트 방식 세그먼트와 간격 칩
  Widget _buildCountOptions(AppLocalizations localizations) {
    // 세로로 쌓는다.
    return Column(
      // 왼쪽 정렬
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // "카운트 방식"
        SectionLabel(localizations.countModeTitle),
        // 방식 선택(진행 중에는 바꿀 수 없다)
        CountModeSelector(
          // 현재 방식
          selectedMode: _controller.countMode,
          // 진행 중이면 비활성, 아니면 바꾸고 저장한다.
          onChanged: _controller.isActive
              ? null
              : (countMode) =>
                    _updateSettings(() => _controller.setCountMode(countMode)),
        ),
        // 자동 간격 방식일 때만 간격 칩을 보여 준다.
        if (_controller.countMode == CountMode.auto) ...<Widget>[
          // 간격
          const SizedBox(height: _mediumSpacing),
          // "절 간격"
          SectionLabel(localizations.intervalTitle),
          // 간격 칩
          IntervalSelector(
            // 현재 간격
            intervalSeconds: _controller.intervalSeconds,
            // 바꾸면 저장한다.
            onChanged: (seconds) =>
                _updateSettings(() => _controller.setIntervalSeconds(seconds)),
          ),
        ],
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
      // 탭하면 즉시 1배
      onTap: _controller.tapCircle,
    );
  }

  // 컨트롤러 값을 바꾼 뒤 설정을 저장한다.
  void _updateSettings(VoidCallback change) {
    // 값을 바꾼다.
    change();
    // 바뀐 설정을 저장한다(완료를 기다리지 않는다).
    unawaited(widget.repository.saveSettings(_controller.settings));
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

  // 시작 버튼: 완료면 회향 화면, 아니면 시작/일시정지
  void _handlePrimaryPressed() {
    // 완료 상태면 회향 화면을 다시 연다.
    if (_controller.isCompleted) {
      // 회향 화면 열기
      unawaited(_openCompletion());
      // 처리 끝
      return;
    }
    // 시작 또는 일시정지
    _controller.toggleStartPause();
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
    // 저장한 경우 알림을 띄운다.
    if (outcome == CompletionOutcome.saved) {
      // 하단 안내
      ScaffoldMessenger.of(context).showSnackBar(
        // "기록을 저장했습니다"
        SnackBar(content: Text(AppLocalizations.of(context).recordSaved)),
      );
    }
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
