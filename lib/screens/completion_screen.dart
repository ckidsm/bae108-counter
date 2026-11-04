import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/bow_session.dart';
import '../services/practice_record_repository.dart';
import '../services/practice_statistics_calculator.dart';
import '../theme/app_colors.dart';
import '../widgets/display_formats.dart';
import '../widgets/stat_tile.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Defines how the completion screen was closed.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// 회향 화면을 닫은 방법.
enum CompletionOutcome {
  // 기록을 저장하고 닫았다.
  /// The record was saved.
  saved,

  // 저장하지 않고 다시 시작하기로 했다.
  /// The user chose to practice again without saving.
  restarted,
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Shows the summary of a completed practice and saves it with a memo.
 Author   : YUNDEOKSOO                          Created : 2026-11-04
────────────────────────────────────────────────────────────────────────*/
/// "108배 회향" 완료 화면.
class CompletionScreen extends StatefulWidget {
  /// Creates the completion screen for [session].
  const CompletionScreen({
    super.key,
    required this.session,
    required this.repository,
  });

  /// The completed practice, without a memo yet.
  final BowSession session;

  /// Stores the record when the user saves it.
  final PracticeRecordRepository repository;

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

// 메모 입력과 저장 상태
class _CompletionScreenState extends State<CompletionScreen> {
  // 메모 최대 글자 수(한 줄 메모)
  static const int _memoMaximumLength = 60;
  // 연꽃 원 지름
  static const double _lotusDiameter = 96;
  // 연꽃 아이콘 크기
  static const double _lotusIconSize = 56;
  // 화면 여백
  static const double _screenPadding = 24;
  // 카드 안쪽 여백
  static const double _cardPadding = 20;
  // 작은 간격
  static const double _smallSpacing = 8;
  // 큰 간격
  static const double _largeSpacing = 24;
  // 버튼 높이
  static const double _buttonHeight = 52;
  // 연꽃 원 배경 투명도
  static const double _lotusBackgroundAlpha = 0.15;

  // 메모 입력 컨트롤러
  final TextEditingController _memoController = TextEditingController();
  // 이번 수행을 포함한 연속 일수
  late final int _streakDays = _calculateStreakDays();
  // 저장 중인지 여부(중복 저장 방지)
  bool _isSaving = false;

  @override
  void dispose() {
    // 입력 컨트롤러를 정리한다.
    _memoController.dispose();
    // 부모 정리를 이어서 한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 글자 스타일
    final textTheme = Theme.of(context).textTheme;
    // 화면 뼈대
    return Scaffold(
      // 투명한 상단 바(뒤로 가기 버튼만)
      appBar: AppBar(),
      // 내용
      body: SafeArea(
        // 키보드가 올라와도 스크롤할 수 있게 한다.
        child: SingleChildScrollView(
          // 화면 여백
          padding: const EdgeInsets.all(_screenPadding),
          // 세로로 쌓는다.
          child: Column(
            children: <Widget>[
              // 연꽃 아이콘
              _buildLotus(),
              // 간격
              const SizedBox(height: _largeSpacing),
              // "108배 회향"
              Text(
                // 제목
                localizations.completionTitle,
                // 굵은 큰 글자
                style: textTheme.headlineMedium?.copyWith(
                  // 굵게
                  fontWeight: FontWeight.w700,
                ),
              ),
              // 간격
              const SizedBox(height: _smallSpacing),
              // 부제
              Text(
                // "오늘의 정진을 모두에게 회향합니다"
                localizations.completionSubtitle,
                // 보조 글자
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              // 간격
              const SizedBox(height: _largeSpacing),
              // 소요 시간·평균·연속 일수 카드
              _buildSummaryCard(localizations),
              // 간격
              const SizedBox(height: _largeSpacing),
              // 한 줄 메모 입력
              TextField(
                // 입력 컨트롤러
                controller: _memoController,
                // 최대 글자 수
                maxLength: _memoMaximumLength,
                // 한 줄
                maxLines: 1,
                // 완료 키
                textInputAction: TextInputAction.done,
                // 입력 칸 꾸밈
                decoration: InputDecoration(
                  // "오늘의 한 줄 메모"
                  hintText: localizations.memoHint,
                  // 연필 아이콘
                  prefixIcon: const Icon(Icons.edit_note),
                  // 바탕 채움
                  filled: true,
                  // 카드 색 바탕
                  fillColor: AppColors.card,
                  // 테두리
                  border: const OutlineInputBorder(),
                ),
              ),
              // 간격
              const SizedBox(height: _largeSpacing),
              // 기록 저장 버튼
              _buildFullWidthButton(
                FilledButton.icon(
                  // 저장 중에는 비활성
                  onPressed: _isSaving ? null : _saveRecord,
                  // 저장 아이콘
                  icon: const Icon(Icons.bookmark_add_outlined),
                  // "기록 저장"
                  label: Text(localizations.saveRecord),
                ),
              ),
              // 간격
              const SizedBox(height: _smallSpacing),
              // 한 번 더 하기 버튼
              _buildFullWidthButton(
                OutlinedButton.icon(
                  // 저장 중에는 비활성
                  onPressed: _isSaving ? null : _confirmRestart,
                  // 다시 아이콘
                  icon: const Icon(Icons.replay),
                  // "한 번 더 하기"
                  label: Text(localizations.restartPractice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 금빛 원 안의 연꽃 아이콘
  Widget _buildLotus() {
    // 원형 배경
    return Container(
      // 지름
      width: _lotusDiameter,
      // 지름
      height: _lotusDiameter,
      // 원 모양 금빛 반투명 배경
      decoration: BoxDecoration(
        // 원
        shape: BoxShape.circle,
        // 반투명 금빛
        color: AppColors.gold.withValues(alpha: _lotusBackgroundAlpha),
      ),
      // 연꽃(spa) 아이콘
      child: const Icon(Icons.spa, size: _lotusIconSize, color: AppColors.gold),
    );
  }

  // 소요 시간·1배 평균·연속 일수와 시작→종료 시각 카드
  Widget _buildSummaryCard(AppLocalizations localizations) {
    // 시간 문구 형식 도우미
    final formatter = DisplayFormatter(localizations);
    // 완료 기록
    final session = widget.session;
    // 1배 평균 시간
    final averageDuration = session.bowCount == 0
        ? Duration.zero
        : session.activeDuration ~/ session.bowCount;
    // 카드
    return Card(
      // 안쪽 여백
      child: Padding(
        // 여백
        padding: const EdgeInsets.all(_cardPadding),
        // 세로로 쌓는다.
        child: Column(
          children: <Widget>[
            // 통계 3칸
            Row(
              // 고르게 배치
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // 소요 시간
                StatTile(
                  // "소요 시간"
                  label: localizations.completionDuration,
                  // "38분 12초"
                  value: formatter.formatDuration(session.activeDuration),
                ),
                // 1배 평균
                StatTile(
                  // "1배 평균"
                  label: localizations.completionAverage,
                  // "21.2초"
                  value: formatter.formatAverageSeconds(averageDuration),
                ),
                // 연속 일수
                StatTile(
                  // "연속 일수"
                  label: localizations.completionStreak,
                  // "3일"
                  value: localizations.streakDaysValue(_streakDays),
                ),
              ],
            ),
            // 구분선
            const Divider(height: _largeSpacing * 2),
            // 시작→종료 시각
            Text(
              // "14:02 → 14:40"
              formatter.formatTimeRange(session.startedAt, session.endedAt),
              // 금빛 글자
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }

  // 버튼을 가로 전체 폭과 고정 높이로 감싼다.
  Widget _buildFullWidthButton(Widget button) {
    // 고정 크기 상자
    return SizedBox(
      // 가로 전체
      width: double.infinity,
      // 버튼 높이
      height: _buttonHeight,
      // 버튼
      child: button,
    );
  }

  // 저장된 기록에 이번 수행을 더해 연속 일수를 계산한다.
  int _calculateStreakDays() {
    // 저장된 기록에 이번 기록을 더한다.
    final sessions = <BowSession>[
      ...widget.repository.loadSessions(),
      widget.session,
    ];
    // 수행 날짜 집합
    final practiceDates = PracticeStatisticsCalculator.collectPracticeDates(
      sessions,
    );
    // 이번 수행 종료일 기준 연속 일수
    return PracticeStatisticsCalculator.currentStreakDays(
      practiceDates,
      widget.session.endedAt,
    );
  }

  // 메모를 붙여 기록을 저장하고 화면을 닫는다.
  Future<void> _saveRecord() async {
    // 저장 중으로 표시한다.
    setState(() => _isSaving = true);
    // 앞뒤 공백을 지운 메모
    final memo = _memoController.text.trim();
    // 저장은 실패할 수 있다.
    try {
      // 메모를 붙여 저장한다.
      await widget.repository.addSession(widget.session.copyWithMemo(memo));
    } on StateError catch (error) {
      // 실패 원인을 남긴다.
      debugPrint('[CompletionScreen] 기록 저장 실패: $error');
      // 화면이 사라졌으면 끝낸다.
      if (!mounted) {
        // 처리 끝
        return;
      }
      // 다시 누를 수 있게 한다.
      setState(() => _isSaving = false);
      // 실패 안내를 띄운다.
      ScaffoldMessenger.of(context).showSnackBar(
        // "기록을 저장하지 못했습니다"
        SnackBar(content: Text(AppLocalizations.of(context).recordSaveFailed)),
      );
      // 화면은 닫지 않는다.
      return;
    }
    // 화면이 사라졌으면 끝낸다.
    if (!mounted) {
      // 처리 끝
      return;
    }
    // 저장했음을 알리며 닫는다.
    Navigator.of(context).pop(CompletionOutcome.saved);
  }

  // 저장하지 않고 다시 시작할지 확인한다.
  Future<void> _confirmRestart() async {
    // 번역 문구
    final localizations = AppLocalizations.of(context);
    // 확인 대화상자를 띄운다.
    final isConfirmed = await showDialog<bool>(
      // 현재 화면 문맥
      context: context,
      // 대화상자 내용
      builder: (dialogContext) => AlertDialog(
        // "기록을 저장하지 않을까요?"
        title: Text(localizations.discardConfirmTitle),
        // 안내 문구
        content: Text(localizations.discardConfirmMessage),
        // 버튼
        actions: <Widget>[
          // 취소
          TextButton(
            // false로 닫는다.
            onPressed: () => Navigator.of(dialogContext).pop(false),
            // "취소"
            child: Text(localizations.dialogCancel),
          ),
          // 저장 안 함
          FilledButton(
            // true로 닫는다.
            onPressed: () => Navigator.of(dialogContext).pop(true),
            // "저장 안 함"
            child: Text(localizations.discardConfirmAction),
          ),
        ],
      ),
    );
    // 확인하지 않았거나 화면이 사라졌으면 끝낸다.
    if (isConfirmed != true || !mounted) {
      // 처리 끝
      return;
    }
    // 다시 시작을 알리며 닫는다.
    Navigator.of(context).pop(CompletionOutcome.restarted);
  }
}
