[English](README.md) | [한국어](README.ko.md)

# 108배 카운터

108배 수행을 탭이나 일정한 간격으로 세고, 마친 수행을 기록하는 Android·iOS 앱입니다. (`pubspec.yaml`, `lib/main.dart`)

## Overview

108배를 하는 동안 화면을 들여다보지 않고도 절 수를 셀 수 있도록 돕는 앱입니다. 시작을 누르면 5초~3분 중 고른 간격마다 자동으로 1배씩 세며, 1배마다 종소리·진동·무음 중 하나로 알려 줍니다. (`lib/controllers/counter_controller.dart`, `lib/services/device_bow_feedback_service.dart`)

108배에 도달하면 카운트가 멈추고 화면 꺼짐 방지가 풀리며, 완료 화면에서 소요 시간·1배 평균·연속 일수를 보여 줍니다. 한 줄 메모와 함께 수행을 저장할 수 있습니다. (`lib/screens/completion_screen.dart`)

저장한 기록은 기기의 `shared_preferences`에 남습니다. 원하면 기기에 로그인된 Google 계정을 포함한 기기 캘린더에 일정으로도 추가할 수 있습니다. (`lib/services/practice_record_repository.dart`, `lib/services/device_calendar_sync_service.dart`)

서버 구성 요소나 자체 계정 기능은 없습니다. Linux 컨테이너에서 정적 분석과 자동 테스트로 검증했고 웹 빌드로 화면을 확인했지만, 실제 Android·iOS 기기에서는 아직 실행해 보지 않았습니다. (`test/`)

## Key Features

- **간격 카운트** – 5초·10초·20초 프리셋 또는 5초~3분(5초 단위)을 설정 화면에서 고릅니다. (`lib/screens/settings_screen.dart`, `lib/widgets/interval_slider.dart`, `lib/controllers/counter_rules.dart`)
- **한 화면 메인** – 메인 화면은 현재 절 간격과 알림을 한 줄로 보여 주고(누르면 설정), 스크롤 없이 한 화면에 들어옵니다. 원형 카운터는 남은 높이에 맞춰 크기가 정해집니다. (`lib/widgets/settings_summary_bar.dart`, `lib/screens/main_screen.dart`, `lib/widgets/counter_ring.dart`)
- **시작 | 정지 | 처음부터** – 시작으로 세기 시작하고, 정지는 센 수를 유지한 채 멈추며, 처음부터는 확인 후 0으로 되돌립니다. (`lib/widgets/counter_controls.dart`, `lib/screens/main_screen.dart`)
- **10초 준비 카운트다운** – 0배부터 시작하면 10→1 카운트다운 뒤에 셈을 시작하고, 정지 후 다시 시작할 때는 건너뜁니다. (`lib/controllers/counter_controller.dart`)
- **1배마다 알림** – 종소리·진동·무음, 108배째는 길게 알립니다. 종소리는 설정에서 중저음 종(기본)·맑은 종·풍경·목탁 중에 고를 수 있고, 소리 파일이 없으면 시스템 클릭음으로 대신합니다. (`lib/services/device_bow_feedback_service.dart`, `assets/sounds/`)
- **화면 켜짐 유지** – 완료하거나 처음부터를 누를 때까지 화면이 꺼지지 않습니다. (`lib/services/wake_lock_service.dart`)
- **진행 표시** – 주황색으로 차오르다 완료 시 녹색으로 바뀌고 녹색 테두리가 생기는 바깥 링, 다음 절까지 남은 시간을 보여 주는 안쪽 링, 27배 단위 구간 바 4개. (`lib/widgets/counter_ring.dart`, `lib/widgets/segment_progress_bars.dart`)
- **수행 기록** – 현재·최장 연속 일수, 이번 주 월~일 체크, 이번 달 수행 횟수와 누적 절 수, 최근 수행 목록. (`lib/screens/history_screen.dart`, `lib/services/practice_statistics_calculator.dart`)
- **설정** – 카운트 간격, 종소리, 배경색(팔레트 #574의 화이트·다크 그레이·라이트 그레이를 포함한 7가지), 버튼색(금빛·블루 #1976D2·딥 블루 #1565C0·그레이 #424242). (`lib/screens/settings_screen.dart`, `lib/theme/app_colors.dart`)
- **캘린더 기록** – 켜 두면 기록을 저장할 때 선택한 기기 캘린더에 시작·종료 시각, 소요 시간, 메모가 담긴 일정을 추가합니다. (`lib/screens/completion_screen.dart`, `lib/services/device_calendar_sync_service.dart`)
- **앱 아이콘과 엠블럼** – 금빛 바탕에 큰절하는 모습과 108을 넣은 앱 아이콘, 메인 제목 옆에는 선택한 색을 따라가는 원형 고행상 엠블럼. 아이콘을 바꾸려면 `assets/icon/app_icon.png`를 교체하고 `dart run flutter_launcher_icons`를 실행합니다. (`assets/icon/`, `flutter_launcher_icons.yaml`, `lib/widgets/ascetic_emblem.dart`)
- **Apple Watch 앱** – 워치에서 절 시작마다 톡톡 두 번, 완료 때 강하게 두 번 진동하며 셉니다. 운동 세션으로 실행되어 화면이 꺼져도 계속되고, 간격은 iPhone 설정을 따르며, 끝난 수행은 iPhone 수행 기록으로 들어옵니다. 워치 타깃은 Xcode에서 한 번 만들어야 합니다(`docs/apple-watch-setup.md`). 아직 워치에서 빌드·실행해 보지 않았습니다. (`ios/WatchAppSources/`, `ios/Runner/AppDelegate.swift`, `lib/services/method_channel_watch_sync_service.dart`)
- **4개 언어** – 한국어·영어·일본어·중국어를 지원하며, 그 외 언어는 영어로 표시합니다. (`lib/l10n/`)

## Concepts / Domain Model

### 진행 단계(Counter phase)

수행은 `idle`(대기), `preparing`(준비), `running`(진행), `paused`(정지), `completed`(완료) 순으로 바뀝니다. 시간은 `CounterController.tick()`으로만 흐르며, 앱에서는 100ms 타이머가 이를 부르고 테스트에서는 직접 부릅니다. (`lib/models/counter_phase.dart`, `lib/controllers/counter_controller.dart`)

### 수행 기록(Bow session)

마친 수행 1회입니다. 시작·종료 시각, 일시정지와 준비 시간을 뺀 실제 수행 시간, 절 수, 메모를 JSON으로 저장합니다. (`lib/models/bow_session.dart`)

### 카운터 설정과 앱 설정

카운터 설정은 카운트 방식·간격·알림 방식을, 앱 설정은 배경색·버튼색·캘린더 기록 여부를 담습니다. 둘 다 다음 실행 때 그대로 복원됩니다. (`lib/models/counter_settings.dart`, `lib/models/app_settings.dart`)

### 기록할 캘린더(Calendar target)

수행 일정을 추가할 기기 캘린더(이름과 계정)입니다. (`lib/models/calendar_target.dart`)

## Architecture

앱은 Flutter 클라이언트 하나로 이루어져 있습니다. `main.dart`가 `shared_preferences`를 열고 기록 저장소, 앱 설정 컨트롤러, 기기 서비스들을 만들어 `Bae108App`에 넘기며, `Bae108App`은 선택한 색으로 테마를 만들고 메인 화면을 띄웁니다. (`lib/main.dart`, `lib/app.dart`)

화면은 상태를 보여 주고 사용자 입력을 넘기는 일만 합니다. 카운트 규칙은 `ChangeNotifier`인 `CounterController`에, 테마와 캘린더 선택은 `AppSettingsController`에 있습니다. 기기 기능은 작은 인터페이스(`BowFeedbackService`, `WakeLockService`, `CalendarSyncService`)를 거치므로 테스트에서 가짜로 바꿀 수 있습니다. 기록과 설정은 `PracticeRecordRepository`만 읽고 씁니다. (`lib/screens/`, `lib/controllers/`, `lib/services/`)

완료한 수행을 저장하면 완료 화면이 저장소에 기록을 쓰고, 캘린더 기록이 켜져 있으면 캘린더 서비스에 일정 추가를 요청합니다. 캘린더 추가에 실패해도 이미 저장한 기록은 그대로 남습니다. (`lib/screens/completion_screen.dart`)

인증·권한 흐름은 없으며, 캘린더 접근은 운영체제의 권한 요청 창으로 허용받습니다. (`lib/services/device_calendar_sync_service.dart`)

## Source Structure

```text
.
├── lib/
│   ├── main.dart              # 진입점: 저장소를 열고 서비스를 만든다
│   ├── app.dart               # MaterialApp, 테마, 지역화
│   ├── controllers/           # CounterController, AppSettingsController, 카운터 규칙
│   ├── models/                # 수행 기록, 설정, 열거형
│   ├── services/              # 저장, 통계, 소리·진동, 화면 켜짐, 캘린더
│   ├── screens/               # 메인, 완료, 수행 기록, 설정
│   ├── widgets/               # 원형 카운터, 선택 위젯, 색 견본, 형식 도우미
│   ├── theme/                 # 색 팔레트와 Material 3 테마
│   └── l10n/                  # .arb 번역 파일과 생성된 지역화 코드
├── assets/sounds/            # 종소리(중저음·맑은 종·풍경·목탁)
├── assets/icon/               # 앱 아이콘 원본(flutter_launcher_icons용)
├── flutter_launcher_icons.yaml # 앱 아이콘 생성 설정
├── test/
│   ├── unit/                  # 컨트롤러, 모델, 서비스 단위 테스트
│   ├── widget/                # 화면 단위 기능 테스트
│   ├── process/               # 처음부터 끝까지 이어지는 수행 흐름 테스트
│   └── support/               # 가짜 서비스와 테스트용 앱 하네스
├── android/                   # Android 프로젝트(권한, R8 규칙)
├── ios/                       # iOS 프로젝트(Info.plist 권한 설명)
├── l10n.yaml                  # 지역화 코드 생성 설정
└── pubspec.yaml               # 의존성과 에셋
```

앱은 `lib/main.dart`에서 시작합니다. (`lib/main.dart`)

## How It Works

1. 메인 화면이 저장된 카운터 설정을 읽어 `CounterController`를 만듭니다. (`lib/screens/main_screen.dart`)
2. 시작을 누르면 화면 켜짐 유지를 켜고, 실제 경과 시간을 재며 `tick()`을 부르는 100ms 타이머를 시작합니다. (`lib/controllers/counter_controller.dart`)
3. 0배부터 시작하면 `tick()`이 먼저 10초 준비 카운트다운을 진행하고, 이후 소리와 함께 각 절을 시작합니다. 준비가 끝나는 순간 소리가 나며 1배가 되고, 그 뒤 간격마다 소리와 함께 다음 절이 됩니다. 소리가 나면 절을 하면 됩니다. (`lib/controllers/counter_controller.dart`)
4. 108배째 절을 시작하고 한 간격이 지나면 긴 소리로 완료를 알리고, 컨트롤러가 타이머를 멈추고 종료 시각을 기록한 뒤 화면 켜짐 유지를 해제합니다. 1.5초 뒤 메인 화면이 완료 화면을 엽니다. (`lib/controllers/counter_controller.dart`, `lib/screens/main_screen.dart`)
5. 저장하면 수행 기록을 JSON으로 `shared_preferences`에 넣고, 켜져 있으면 캘린더에 일정을 추가합니다. 그 뒤 메인 화면이 카운터를 초기화합니다. (`lib/screens/completion_screen.dart`, `lib/services/practice_record_repository.dart`)
6. 수행 기록 화면은 모든 기록을 읽어 연속 일수, 이번 주 체크, 이번 달 합계를 계산합니다. (`lib/screens/history_screen.dart`, `lib/services/practice_statistics_calculator.dart`)

## Setup & Run

### 요구 사항

- Dart SDK `^3.13.0`을 포함한 Flutter 3.44.0 이상 (Flutter 3.47.9로 개발). (`pubspec.yaml`, `pubspec.lock`)
- Android: Android SDK, `minSdk`는 Flutter 기본값을 따릅니다. (`android/app/build.gradle.kts`)
- iOS: Xcode와 CocoaPods가 설치된 macOS, 배포 대상 iOS 15.0. (`ios/Runner.xcodeproj/project.pbxproj`)

### 설치와 실행

```bash
git clone https://github.com/ckidsm/bae108-counter.git
```

```bash
cd bae108-counter
```

```bash
flutter pub get
```

```bash
flutter run
```

iOS 기기에서 실행하기 전에 Xcode로 `ios/Runner.xcworkspace`를 한 번 열어 Signing & Capabilities에서 개발 팀을 선택하세요.

### 릴리스 빌드

```bash
flutter build apk --release
```

```bash
flutter build ios --release
```

Android 릴리스 빌드는 현재 디버그 키로 서명됩니다. 배포 전에 `android/app/build.gradle.kts`에서 서명 설정을 바꾸세요. (`android/app/build.gradle.kts`)

### 검사

```bash
dart format --output=none --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

테스트는 `test/unit`, `test/widget`, `test/process`로 나뉘어 있어 `flutter test test/process`처럼 폴더별로 실행할 수 있습니다. (`test/`)

### 환경변수

없습니다. 앱은 환경변수를 읽지 않습니다. (`lib/`)

## Server Requirements / Spec

해당 없음. 앱은 기기 안에서만 동작하며 서버가 없습니다. (`lib/`)

- 포트: 해당 없음
- 최소 CPU·메모리: 정보 없음
- 저장 공간: 정보 없음. 기록은 `shared_preferences`의 작은 JSON 문자열입니다. (`lib/services/practice_record_repository.dart`)

## Operations

- 로그: 저장·알림·화면 켜짐·캘린더 실패는 `debugPrint`로 남깁니다. (`lib/services/`, `lib/controllers/counter_controller.dart`)
- 데이터: 기록은 `bow_sessions_v1` 키에, 설정은 `counter_settings_v1`과 `app_settings_v1` 키에 저장합니다. 저장된 JSON이 깨져 있으면 로그를 남기고 빈 값으로 처리합니다. (`lib/services/practice_record_repository.dart`)
- 백업·마이그레이션·배포: 정보 없음.

## Security Notes

- 인증: 없음. 계정 기능이 없습니다. (`lib/`)
- 권한: Android `VIBRATE`, `READ_CALENDAR`, `WRITE_CALENDAR`, iOS 캘린더 사용 설명. `NSContactsUsageDescription`은 캘린더 플러그인이 요구해서 들어 있으며, 앱은 연락처를 읽지 않습니다. (`android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`)
- 데이터: 수행 기록과 메모는 기기 안에만 남습니다. 캘린더 기록을 켜면 선택한 캘린더에 쓰이고, 그 캘린더 계정을 통해 동기화됩니다. (`lib/services/device_calendar_sync_service.dart`)

## Troubleshooting

### 캘린더 기록을 켜도 캘린더 목록이 나오지 않음

- 증상: "쓸 수 있는 캘린더가 없습니다" 안내가 뜹니다.
- 확인: 시스템 설정에서 Google 계정이 기기에 추가되어 있고 캘린더 동기화가 켜져 있는지 확인합니다.
- 해결: 계정을 추가하고 캘린더 동기화를 기다린 뒤 스위치를 다시 켭니다. (`lib/screens/settings_screen.dart`)

### 캘린더 권한이 거부됨

- 증상: 권한 안내가 뜨고 스위치가 꺼진 채로 남습니다.
- 해결: 기기 설정에서 앱의 캘린더 접근을 허용한 뒤 스위치를 다시 켭니다. (`lib/services/device_calendar_sync_service.dart`)

### Android 릴리스 빌드에서만 캘린더 목록이 비어 있음

- 확인: `android/app/proguard-rules.pro`에 `com.builttoroam.devicecalendar` 유지 규칙이 남아 있어야 합니다. (`android/app/proguard-rules.pro`, `android/app/build.gradle.kts`)

### 종소리가 나지 않음

- 확인: 기기가 무음 모드가 아닌지, `assets/sounds/bell.mp3`가 있고 `pubspec.yaml`의 `assets/sounds/`에 등록되어 있는지 확인합니다. 파일이 없으면 시스템 클릭음으로 대신합니다. (`lib/services/device_bow_feedback_service.dart`)

## License / Disclaimer

라이선스 정보가 명시되어 있지 않습니다.
