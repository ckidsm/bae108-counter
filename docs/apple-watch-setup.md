# Apple Watch 앱 설정 (Xcode)

워치 앱 소스는 `ios/WatchAppSources/`에 있습니다. Flutter는 watchOS 타깃을 만들지 못하므로, Mac의 Xcode에서 한 번만 타깃을 만들고 소스를 연결합니다. (`ios/WatchAppSources/`)

> 이 소스는 Linux 환경에서 작성되어 아직 Xcode로 빌드해 보지 않았습니다. 빌드 오류가 나면 오류 메시지를 그대로 알려 주세요.

## 동작

- 워치에서 ▶ 시작 → 10초 준비 → 손목이 **톡톡(두 번)** 두드리면 절을 시작합니다. 이후 설정한 간격마다 톡톡.
- 108배째 절의 간격이 끝나면 **강하게 두 번** 진동하고 완료됩니다.
- 운동 세션(심신 운동)으로 실행되므로 손목을 내려 화면이 꺼져도 진동이 제때 옵니다. 끝난 수행은 건강 앱에 운동으로 저장되고, iPhone 앱 수행 기록에도 자동으로 들어갑니다.
- 절 간격은 iPhone 앱 설정에서 바꾸면 워치로 전달됩니다(워치에서 진행 중일 때는 다음 수행부터 적용).

## 1. 워치 타깃 만들기

1. `ios/Runner.xcworkspace`를 Xcode로 엽니다.
2. **File → New → Target…** → **watchOS** 탭 → **App** → Next.
3. 다음과 같이 입력합니다.
   - Product Name: `Bae108Watch`
   - Team: `RRTB256N59`
   - Interface: SwiftUI, Language: Swift
   - **Watch App for Existing iOS App**를 고르고, Companion App: `Runner`
4. Finish. "Activate scheme?" 창이 뜨면 **Cancel**을 누릅니다(Runner 스킴 유지).

## 2. 소스 연결

1. 왼쪽 목록에 생긴 **Bae108Watch Watch App** 그룹에서 Xcode가 만든 `Bae108WatchApp.swift`, `ContentView.swift`를 선택 → Delete → **Move to Trash**.
2. Finder에서 `ios/WatchAppSources/`의 파일 7개를 **Bae108Watch Watch App** 그룹으로 끌어 놓습니다.
   - **Copy items if needed: 체크 해제**
   - Add to targets: **Bae108Watch Watch App만** 체크

## 3. 권한과 백그라운드 실행

**Bae108Watch Watch App** 타깃을 고르고:

1. **Signing & Capabilities** → **+ Capability** → **HealthKit** 추가.
2. **+ Capability** → **Background Modes** 추가 → **Workout processing** 체크.
3. **Info** 탭에 두 항목 추가:
   - `Privacy - Health Share Usage Description`: `운동 중 심박수를 기록에 함께 남깁니다.`
   - `Privacy - Health Update Usage Description`: `108배 수행을 건강 앱에 운동으로 저장합니다.`
4. **General** → Minimum Deployments: watchOS **10.0**.

## 4. 실행

- 워치에서 바로: 스킴을 **Bae108Watch Watch App**, 대상을 짝지은 워치로 고르고 ▶.
- iPhone 앱과 함께: 평소처럼 `./tool/deploy_ios.sh`로 iPhone 앱을 설치하면 워치 앱이 함께 들어갑니다. 워치에 자동으로 안 깔리면 iPhone의 **Watch 앱 → 사용 가능한 앱**에서 설치합니다.
- 처음 실행 때 건강 데이터 권한을 허용해야 화면이 꺼져도 진동이 옵니다. 거부하면 화면이 켜져 있는 동안만 동작합니다.

## 문제 해결

- **워치에서 시작했는데 화면이 꺼지면 진동이 멈춤**: 건강 권한(운동 저장) 허용 여부와 Background Modes의 Workout processing을 확인합니다.
- **iPhone 설정의 간격이 워치에 안 바뀜**: 워치 앱을 한 번 열어 두고 iPhone 앱에서 간격을 다시 바꿉니다. 워치에서 수행 중일 때는 박자가 바뀌지 않도록 다음 수행부터 적용됩니다.
- **워치 수행 기록이 iPhone에 안 들어옴**: iPhone 앱을 한 번 열면 쌓여 있던 기록을 가져옵니다(같은 기록은 한 번만 저장).
