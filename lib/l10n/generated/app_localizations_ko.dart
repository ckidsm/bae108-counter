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
  String customIntervalRange(String minimum, String maximum, String step) {
    return '$minimum ~ $maximum, $step 단위';
  }

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
  String guidePreparing(int seconds) {
    return '자세를 갖추세요 · $seconds초 후 시작';
  }

  @override
  String get guidePaused => '정지됨 · 시작을 누르면 이어서 셉니다';

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

  @override
  String get settingsTooltip => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsIntervalSection => '카운트 간격';

  @override
  String get settingsIntervalDescription => '시작하면 이 간격마다 1배씩 셉니다';

  @override
  String get settingsThemeSection => '색상 테마';

  @override
  String get themeBlack => '검정';

  @override
  String get themeCharcoal => '차콜';

  @override
  String get themeWarmBrown => '웜 브라운';

  @override
  String get themeNavy => '네이비';

  @override
  String get settingsCalendarSection => '캘린더 기록';

  @override
  String get calendarSyncTitle => '수행 기록을 캘린더에 추가';

  @override
  String get calendarSyncDescription =>
      '기록을 저장하면 선택한 캘린더(Google 캘린더 등)에 일정으로 추가합니다';

  @override
  String get calendarTargetLabel => '기록할 캘린더';

  @override
  String get calendarNotSelected => '선택 안 됨';

  @override
  String get calendarPickerTitle => '캘린더 선택';

  @override
  String get calendarEmpty =>
      '쓸 수 있는 캘린더가 없습니다. 기기에 Google 계정이 추가되어 있는지 확인해 주세요';

  @override
  String get calendarPermissionDenied =>
      '캘린더 권한이 없습니다. 기기 설정에서 캘린더 접근을 허용해 주세요';

  @override
  String get calendarLoadFailed => '캘린더 목록을 불러오지 못했습니다';

  @override
  String get calendarEventTitle => '108배 수행';

  @override
  String calendarEventDescription(int count, String duration) {
    return '$count배 · 소요 시간 $duration';
  }

  @override
  String get recordSavedToCalendar => '기록을 저장하고 캘린더에 추가했습니다';

  @override
  String get recordSavedCalendarFailed => '기록은 저장했지만 캘린더에 추가하지 못했습니다';

  @override
  String get themeBackgroundLabel => '배경색';

  @override
  String get themeAccentLabel => '버튼색';

  @override
  String get themeDarkGray => '다크 그레이';

  @override
  String get themeWhite => '화이트';

  @override
  String get themeLightGray => '라이트 그레이';

  @override
  String get accentGold => '금빛';

  @override
  String get accentBlue => '블루';

  @override
  String get accentDeepBlue => '딥 블루';

  @override
  String get accentGray => '그레이';

  @override
  String guideRunning(int seconds) {
    return '다음 절까지 $seconds초';
  }

  @override
  String get buttonStop => '정지';

  @override
  String guideIdle(int seconds, String interval) {
    return '시작하면 $seconds초 준비 후 $interval마다 1배씩 셉니다';
  }

  @override
  String get settingsSoundSection => '종소리';

  @override
  String get settingsSoundDescription =>
      '알림 방식이 종소리일 때 울리는 소리입니다. 누르면 바로 들어 볼 수 있습니다';

  @override
  String get soundDeep => '중저음 종';

  @override
  String get soundClear => '맑은 종';

  @override
  String get soundChime => '풍경';

  @override
  String get soundMoktak => '목탁';

  @override
  String get soundTempleBell => '범종';

  @override
  String get summaryIntervalLabel => '절 간격';

  @override
  String get summaryAlertLabel => '알림';

  @override
  String summaryBellValue(String mode, String sound) {
    return '$mode · $sound';
  }
}
