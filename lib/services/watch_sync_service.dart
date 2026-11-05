import '../models/bow_session.dart';
import '../models/counter_settings.dart';

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Abstracts syncing settings to the Apple Watch app and receiving its records.
 Remarks  : Platforms without a watch use a no-op implementation.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// Apple Watch 앱과 설정·수행 기록을 주고받는 서비스 계약.
abstract interface class WatchSyncService {
  /// Sends [settings] so the watch counts at the same interval.
  Future<void> sendSettings(CounterSettings settings);

  /// Returns and clears the practices completed on the watch since the last call.
  Future<List<BowSession>> takeCompletedSessions();

  /// Emits whenever the watch has delivered new practices to take.
  Stream<void> get sessionsAvailable;
}

/*────────────────────────────────────────────────────────────────────────
 Purpose  : Does nothing on platforms that cannot pair with an Apple Watch.
 Author   : YUNDEOKSOO                          Created : 2026-11-05
────────────────────────────────────────────────────────────────────────*/
/// 워치를 쓸 수 없는 플랫폼(Android 등)용 빈 구현.
final class NoopWatchSyncService implements WatchSyncService {
  /// Creates the no-op service.
  const NoopWatchSyncService();

  @override
  Future<void> sendSettings(CounterSettings settings) async {}

  @override
  Future<List<BowSession>> takeCompletedSessions() async => <BowSession>[];

  @override
  Stream<void> get sessionsAvailable => const Stream<void>.empty();
}
