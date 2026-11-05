import Foundation
import HealthKit

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts the workout session so the counter logic can be tested without HealthKit.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@MainActor
protocol WorkoutControlling {
  /// Starts a workout so the app keeps running with the screen off.
  func begin()
  /// Ends the workout and saves it to the Health app.
  func finish()
  /// Ends the workout without saving it.
  func discard()
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Runs a HealthKit workout session for the duration of a practice.
 Remarks  : The session keeps the watch app alive with the wrist down, so the
            bow-start taps arrive on time. Heart rate and energy are collected
            automatically and the finished workout appears in the Health app.
            If permission is denied the counter still works while the screen is on.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
@MainActor
final class WorkoutSessionManager: WorkoutControlling {
  // 건강 데이터 저장소
  private let healthStore = HKHealthStore()
  // 진행 중인 운동 세션
  private var session: HKWorkoutSession?
  // 운동 기록을 모으는 빌더
  private var builder: HKLiveWorkoutBuilder?

  /// Asks for permission to save workouts and read heart rate.
  func requestAuthorization() {
    // 건강 데이터를 쓸 수 없는 기기면 끝낸다.
    guard HKHealthStore.isHealthDataAvailable() else { return }
    // 저장할 데이터: 운동
    let shareTypes: Set<HKSampleType> = [HKObjectType.workoutType()]
    // 읽을 데이터: 심박수(운동 중 표시·기록용)
    let readTypes: Set<HKObjectType> = [HKQuantityType(.heartRate)]
    // 권한을 요청한다.
    healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { _, error in
      // 실패 원인을 남긴다.
      if let error { NSLog("[Workout] 권한 요청 실패: \(error.localizedDescription)") }
    }
  }

  func begin() {
    // 이미 열려 있으면 끝낸다.
    guard session == nil else { return }
    // 운동 종류: 심신 운동, 실내
    let configuration = HKWorkoutConfiguration()
    // 심신 운동
    configuration.activityType = .mindAndBody
    // 실내
    configuration.locationType = .indoor
    // 세션 생성은 실패할 수 있다.
    do {
      // 세션 생성
      let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
      // 기록 빌더
      let newBuilder = newSession.associatedWorkoutBuilder()
      // 심박수 등을 자동으로 모은다.
      newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
      // 시작 시각
      let startDate = Date()
      // 세션 시작
      newSession.startActivity(with: startDate)
      // 기록 수집 시작
      newBuilder.beginCollection(withStart: startDate) { _, error in
        // 실패 원인을 남긴다.
        if let error { NSLog("[Workout] 기록 시작 실패: \(error.localizedDescription)") }
      }
      // 보관
      session = newSession
      builder = newBuilder
    } catch {
      // 권한이 없으면 여기로 온다. 화면이 켜져 있는 동안은 카운트가 계속된다.
      NSLog("[Workout] 세션 시작 실패: \(error.localizedDescription)")
    }
  }

  func finish() {
    // 세션과 빌더가 있어야 저장한다.
    guard let session, let builder else { return }
    // 종료 시각
    let endDate = Date()
    // 세션 종료
    session.end()
    // 기록 수집을 끝내고 건강 앱에 저장한다.
    builder.endCollection(withEnd: endDate) { _, error in
      // 실패하면 남기고 끝낸다.
      if let error {
        // 실패 원인
        NSLog("[Workout] 기록 종료 실패: \(error.localizedDescription)")
        // 끝
        return
      }
      // 운동 기록 저장
      builder.finishWorkout { _, error in
        // 실패 원인을 남긴다.
        if let error { NSLog("[Workout] 운동 저장 실패: \(error.localizedDescription)") }
      }
    }
    // 참조 해제
    clear()
  }

  func discard() {
    // 세션이 없으면 끝낸다.
    guard let session, let builder else { return }
    // 세션 종료
    session.end()
    // 모은 기록을 버린다.
    builder.discardWorkout()
    // 참조 해제
    clear()
  }

  // 세션 참조를 지운다.
  private func clear() {
    // 세션
    session = nil
    // 빌더
    builder = nil
  }
}
