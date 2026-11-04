import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'108배 카운터'**
  String get appTitle;

  /// No description provided for @mainTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 108배'**
  String get mainTitle;

  /// No description provided for @keepScreenOnNotice.
  ///
  /// In ko, this message translates to:
  /// **'108배까지 화면 켜짐 유지'**
  String get keepScreenOnNotice;

  /// No description provided for @historyTooltip.
  ///
  /// In ko, this message translates to:
  /// **'수행 기록'**
  String get historyTooltip;

  /// No description provided for @countModeTitle.
  ///
  /// In ko, this message translates to:
  /// **'카운트 방식'**
  String get countModeTitle;

  /// No description provided for @countModeTap.
  ///
  /// In ko, this message translates to:
  /// **'직접 탭'**
  String get countModeTap;

  /// No description provided for @countModeAuto.
  ///
  /// In ko, this message translates to:
  /// **'자동 간격'**
  String get countModeAuto;

  /// No description provided for @intervalTitle.
  ///
  /// In ko, this message translates to:
  /// **'절 간격'**
  String get intervalTitle;

  /// No description provided for @intervalCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 설정'**
  String get intervalCustom;

  /// No description provided for @intervalCustomSelected.
  ///
  /// In ko, this message translates to:
  /// **'직접 · {duration}'**
  String intervalCustomSelected(String duration);

  /// No description provided for @customIntervalSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'절 간격 직접 설정'**
  String get customIntervalSheetTitle;

  /// No description provided for @customIntervalRange.
  ///
  /// In ko, this message translates to:
  /// **'{minimum} ~ {maximum}, {step} 단위'**
  String customIntervalRange(String minimum, String maximum, String step);

  /// No description provided for @customIntervalApply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get customIntervalApply;

  /// No description provided for @durationSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{seconds}초'**
  String durationSeconds(int seconds);

  /// No description provided for @durationMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String durationMinutes(int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 {seconds}초'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @counterTarget.
  ///
  /// In ko, this message translates to:
  /// **'/ {target}'**
  String counterTarget(int target);

  /// No description provided for @preparationLabel.
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get preparationLabel;

  /// No description provided for @segmentRange.
  ///
  /// In ko, this message translates to:
  /// **'{start}–{end}'**
  String segmentRange(int start, int end);

  /// No description provided for @guideIdleTap.
  ///
  /// In ko, this message translates to:
  /// **'원을 탭하거나 시작을 누르세요'**
  String get guideIdleTap;

  /// No description provided for @guideIdleAuto.
  ///
  /// In ko, this message translates to:
  /// **'시작하면 {seconds}초 준비 후 셈을 시작합니다'**
  String guideIdleAuto(int seconds);

  /// No description provided for @guidePreparing.
  ///
  /// In ko, this message translates to:
  /// **'자세를 갖추세요 · {seconds}초 후 시작'**
  String guidePreparing(int seconds);

  /// No description provided for @guideRunningTap.
  ///
  /// In ko, this message translates to:
  /// **'원을 탭할 때마다 1배씩 셉니다'**
  String get guideRunningTap;

  /// No description provided for @guideRunningAuto.
  ///
  /// In ko, this message translates to:
  /// **'다음 절까지 {seconds}초'**
  String guideRunningAuto(int seconds);

  /// No description provided for @guidePaused.
  ///
  /// In ko, this message translates to:
  /// **'일시정지 중 · 이어서를 누르세요'**
  String get guidePaused;

  /// No description provided for @guideCompleted.
  ///
  /// In ko, this message translates to:
  /// **'108배를 모두 마쳤습니다'**
  String get guideCompleted;

  /// No description provided for @alertModeTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 방식'**
  String get alertModeTitle;

  /// No description provided for @alertModeBell.
  ///
  /// In ko, this message translates to:
  /// **'종소리'**
  String get alertModeBell;

  /// No description provided for @alertModeVibration.
  ///
  /// In ko, this message translates to:
  /// **'진동'**
  String get alertModeVibration;

  /// No description provided for @alertModeSilent.
  ///
  /// In ko, this message translates to:
  /// **'무음'**
  String get alertModeSilent;

  /// No description provided for @buttonStart.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get buttonStart;

  /// No description provided for @buttonResume.
  ///
  /// In ko, this message translates to:
  /// **'이어서'**
  String get buttonResume;

  /// No description provided for @buttonPause.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get buttonPause;

  /// No description provided for @buttonDedication.
  ///
  /// In ko, this message translates to:
  /// **'회향하기'**
  String get buttonDedication;

  /// No description provided for @buttonReset.
  ///
  /// In ko, this message translates to:
  /// **'처음부터'**
  String get buttonReset;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'처음부터 다시 할까요?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'지금까지 센 {count}배가 사라집니다.'**
  String resetConfirmMessage(int count);

  /// No description provided for @dialogCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get dialogConfirm;

  /// No description provided for @completionTitle.
  ///
  /// In ko, this message translates to:
  /// **'108배 회향'**
  String get completionTitle;

  /// No description provided for @completionSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 정진을 모두에게 회향합니다'**
  String get completionSubtitle;

  /// No description provided for @completionDuration.
  ///
  /// In ko, this message translates to:
  /// **'소요 시간'**
  String get completionDuration;

  /// No description provided for @completionAverage.
  ///
  /// In ko, this message translates to:
  /// **'1배 평균'**
  String get completionAverage;

  /// No description provided for @completionStreak.
  ///
  /// In ko, this message translates to:
  /// **'연속 일수'**
  String get completionStreak;

  /// No description provided for @averageSecondsValue.
  ///
  /// In ko, this message translates to:
  /// **'{seconds}초'**
  String averageSecondsValue(String seconds);

  /// No description provided for @streakDaysValue.
  ///
  /// In ko, this message translates to:
  /// **'{days}일'**
  String streakDaysValue(int days);

  /// No description provided for @timeRange.
  ///
  /// In ko, this message translates to:
  /// **'{start} → {end}'**
  String timeRange(String start, String end);

  /// No description provided for @memoHint.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 한 줄 메모'**
  String get memoHint;

  /// No description provided for @saveRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 저장'**
  String get saveRecord;

  /// No description provided for @restartPractice.
  ///
  /// In ko, this message translates to:
  /// **'한 번 더 하기'**
  String get restartPractice;

  /// No description provided for @discardConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장하지 않을까요?'**
  String get discardConfirmTitle;

  /// No description provided for @discardConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장하지 않고 다시 시작하면 이번 수행은 기록에 남지 않습니다.'**
  String get discardConfirmMessage;

  /// No description provided for @discardConfirmAction.
  ///
  /// In ko, this message translates to:
  /// **'저장 안 함'**
  String get discardConfirmAction;

  /// No description provided for @recordSaved.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장했습니다'**
  String get recordSaved;

  /// No description provided for @recordSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장하지 못했습니다. 다시 시도해 주세요'**
  String get recordSaveFailed;

  /// No description provided for @historyTitle.
  ///
  /// In ko, this message translates to:
  /// **'수행 기록'**
  String get historyTitle;

  /// No description provided for @streakTitle.
  ///
  /// In ko, this message translates to:
  /// **'연속 수행'**
  String get streakTitle;

  /// No description provided for @currentStreakLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get currentStreakLabel;

  /// No description provided for @longestStreakLabel.
  ///
  /// In ko, this message translates to:
  /// **'최장'**
  String get longestStreakLabel;

  /// No description provided for @thisWeekTitle.
  ///
  /// In ko, this message translates to:
  /// **'이번 주'**
  String get thisWeekTitle;

  /// No description provided for @thisMonthTitle.
  ///
  /// In ko, this message translates to:
  /// **'이번 달'**
  String get thisMonthTitle;

  /// No description provided for @monthlySessionLabel.
  ///
  /// In ko, this message translates to:
  /// **'수행 횟수'**
  String get monthlySessionLabel;

  /// No description provided for @monthlySessionValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String monthlySessionValue(int count);

  /// No description provided for @monthlyBowLabel.
  ///
  /// In ko, this message translates to:
  /// **'누적 절 수'**
  String get monthlyBowLabel;

  /// No description provided for @monthlyBowValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}절'**
  String monthlyBowValue(int count);

  /// No description provided for @recentSessionsTitle.
  ///
  /// In ko, this message translates to:
  /// **'최근 수행'**
  String get recentSessionsTitle;

  /// No description provided for @emptyHistory.
  ///
  /// In ko, this message translates to:
  /// **'아직 저장된 기록이 없습니다'**
  String get emptyHistory;

  /// No description provided for @settingsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsIntervalSection.
  ///
  /// In ko, this message translates to:
  /// **'카운트 간격'**
  String get settingsIntervalSection;

  /// No description provided for @settingsIntervalDescription.
  ///
  /// In ko, this message translates to:
  /// **'자동 간격 방식에서 1배를 세는 간격입니다'**
  String get settingsIntervalDescription;

  /// No description provided for @settingsThemeSection.
  ///
  /// In ko, this message translates to:
  /// **'색상 테마'**
  String get settingsThemeSection;

  /// No description provided for @themeBlack.
  ///
  /// In ko, this message translates to:
  /// **'검정'**
  String get themeBlack;

  /// No description provided for @themeCharcoal.
  ///
  /// In ko, this message translates to:
  /// **'차콜'**
  String get themeCharcoal;

  /// No description provided for @themeWarmBrown.
  ///
  /// In ko, this message translates to:
  /// **'웜 브라운'**
  String get themeWarmBrown;

  /// No description provided for @themeNavy.
  ///
  /// In ko, this message translates to:
  /// **'네이비'**
  String get themeNavy;

  /// No description provided for @settingsCalendarSection.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 기록'**
  String get settingsCalendarSection;

  /// No description provided for @calendarSyncTitle.
  ///
  /// In ko, this message translates to:
  /// **'수행 기록을 캘린더에 추가'**
  String get calendarSyncTitle;

  /// No description provided for @calendarSyncDescription.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장하면 선택한 캘린더(Google 캘린더 등)에 일정으로 추가합니다'**
  String get calendarSyncDescription;

  /// No description provided for @calendarTargetLabel.
  ///
  /// In ko, this message translates to:
  /// **'기록할 캘린더'**
  String get calendarTargetLabel;

  /// No description provided for @calendarNotSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택 안 됨'**
  String get calendarNotSelected;

  /// No description provided for @calendarPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 선택'**
  String get calendarPickerTitle;

  /// No description provided for @calendarEmpty.
  ///
  /// In ko, this message translates to:
  /// **'쓸 수 있는 캘린더가 없습니다. 기기에 Google 계정이 추가되어 있는지 확인해 주세요'**
  String get calendarEmpty;

  /// No description provided for @calendarPermissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 권한이 없습니다. 기기 설정에서 캘린더 접근을 허용해 주세요'**
  String get calendarPermissionDenied;

  /// No description provided for @calendarLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 목록을 불러오지 못했습니다'**
  String get calendarLoadFailed;

  /// No description provided for @calendarEventTitle.
  ///
  /// In ko, this message translates to:
  /// **'108배 수행'**
  String get calendarEventTitle;

  /// No description provided for @calendarEventDescription.
  ///
  /// In ko, this message translates to:
  /// **'{count}배 · 소요 시간 {duration}'**
  String calendarEventDescription(int count, String duration);

  /// No description provided for @recordSavedToCalendar.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장하고 캘린더에 추가했습니다'**
  String get recordSavedToCalendar;

  /// No description provided for @recordSavedCalendarFailed.
  ///
  /// In ko, this message translates to:
  /// **'기록은 저장했지만 캘린더에 추가하지 못했습니다'**
  String get recordSavedCalendarFailed;

  /// No description provided for @themeBackgroundLabel.
  ///
  /// In ko, this message translates to:
  /// **'배경색'**
  String get themeBackgroundLabel;

  /// No description provided for @themeAccentLabel.
  ///
  /// In ko, this message translates to:
  /// **'버튼색'**
  String get themeAccentLabel;

  /// No description provided for @themeDarkGray.
  ///
  /// In ko, this message translates to:
  /// **'다크 그레이'**
  String get themeDarkGray;

  /// No description provided for @themeWhite.
  ///
  /// In ko, this message translates to:
  /// **'화이트'**
  String get themeWhite;

  /// No description provided for @themeLightGray.
  ///
  /// In ko, this message translates to:
  /// **'라이트 그레이'**
  String get themeLightGray;

  /// No description provided for @accentGold.
  ///
  /// In ko, this message translates to:
  /// **'금빛'**
  String get accentGold;

  /// No description provided for @accentBlue.
  ///
  /// In ko, this message translates to:
  /// **'블루'**
  String get accentBlue;

  /// No description provided for @accentDeepBlue.
  ///
  /// In ko, this message translates to:
  /// **'딥 블루'**
  String get accentDeepBlue;

  /// No description provided for @accentGray.
  ///
  /// In ko, this message translates to:
  /// **'그레이'**
  String get accentGray;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
