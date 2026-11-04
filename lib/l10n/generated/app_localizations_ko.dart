// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '108배 카운터';

  @override
  String get mainTitle => '오늘의 108배';

  @override
  String get keepScreenOnNotice => '108배까지 화면 켜짐 유지';

  @override
  String get historyTooltip => '수행 기록';

  @override
  String get countModeTitle => '카운트 방식';

  @override
  String get countModeTap => '직접 탭';

  @override
  String get countModeAuto => '자동 간격';

  @override
  String get intervalTitle => '절 간격';

  @override
  String get intervalCustom => '직접 설정';

  @override
  String intervalCustomSelected(String duration) {
    return '직접 · $duration';
  }

  @override
  String get customIntervalSheetTitle => '절 간격 직접 설정';

  @override
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum ~ $maximum, $step 단위';
  }

  @override
  String get customIntervalApply => '적용';

  @override
  String durationSeconds(int seconds) {
    return '$seconds초';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String counterTarget(int target) {
    return '/ $target';
  }

  @override
  String get preparationLabel => '준비';

  @override
  String segmentRange(int start, int end) {
    return '$start–$end';
  }

  @override
  String get guideIdleTap => '원을 탭하거나 시작을 누르세요';

  @override
  String guideIdleAuto(int seconds) {
    return '시작하면 $seconds초 준비 후 셈을 시작합니다';
  }

  @override
  String guidePreparing(int seconds) {
    return '자세를 갖추세요 · $seconds초 후 시작';
  }

  @override
  String get guideRunningTap => '원을 탭할 때마다 1배씩 셉니다';

  @override
  String guideRunningAuto(int seconds) {
    return '다음 절까지 $seconds초';
  }

  @override
  String get guidePaused => '일시정지 중 · 이어서를 누르세요';

  @override
  String get guideCompleted => '108배를 모두 마쳤습니다';

  @override
  String get alertModeTitle => '알림 방식';

  @override
  String get alertModeBell => '종소리';

  @override
  String get alertModeVibration => '진동';

  @override
  String get alertModeSilent => '무음';

  @override
  String get buttonStart => '시작';

  @override
  String get buttonResume => '이어서';

  @override
  String get buttonPause => '일시정지';

  @override
  String get buttonDedication => '회향하기';

  @override
  String get buttonReset => '처음부터';

  @override
  String get resetConfirmTitle => '처음부터 다시 할까요?';

  @override
  String resetConfirmMessage(int count) {
    return '지금까지 센 $count배가 사라집니다.';
  }

  @override
  String get dialogCancel => '취소';

  @override
  String get dialogConfirm => '확인';

  @override
  String get completionTitle => '108배 회향';

  @override
  String get completionSubtitle => '오늘의 정진을 모두에게 회향합니다';

  @override
  String get completionDuration => '소요 시간';

  @override
  String get completionAverage => '1배 평균';

  @override
  String get completionStreak => '연속 일수';

  @override
  String averageSecondsValue(String seconds) {
    return '$seconds초';
  }

  @override
  String streakDaysValue(int days) {
    return '$days일';
  }

  @override
  String timeRange(String start, String end) {
    return '$start → $end';
  }

  @override
  String get memoHint => '오늘의 한 줄 메모';

  @override
  String get saveRecord => '기록 저장';

  @override
  String get restartPractice => '한 번 더 하기';

  @override
  String get discardConfirmTitle => '기록을 저장하지 않을까요?';

  @override
  String get discardConfirmMessage => '저장하지 않고 다시 시작하면 이번 수행은 기록에 남지 않습니다.';

  @override
  String get discardConfirmAction => '저장 안 함';

  @override
  String get recordSaved => '기록을 저장했습니다';

  @override
  String get recordSaveFailed => '기록을 저장하지 못했습니다. 다시 시도해 주세요';

  @override
  String get historyTitle => '수행 기록';

  @override
  String get streakTitle => '연속 수행';

  @override
  String get currentStreakLabel => '현재';

  @override
  String get longestStreakLabel => '최장';

  @override
  String get thisWeekTitle => '이번 주';

  @override
  String get thisMonthTitle => '이번 달';

  @override
  String get monthlySessionLabel => '수행 횟수';

  @override
  String monthlySessionValue(int count) {
    return '$count회';
  }

  @override
  String get monthlyBowLabel => '누적 절 수';

  @override
  String monthlyBowValue(int count) {
    return '$count절';
  }

  @override
  String get recentSessionsTitle => '최근 수행';

  @override
  String get emptyHistory => '아직 저장된 기록이 없습니다';
}
