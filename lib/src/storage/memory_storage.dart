import '../models/counter_data.dart';
import '../services/counter_storage.dart';

/// Pure-Dart, in-memory [CounterStorage] used as the zero-configuration default.
///
/// It has **no native plugin dependencies**, so it works on every platform
/// (including Windows without Developer Mode) out of the box. Counters live only
/// for the lifetime of the process — they are *not* persisted across restarts.
///
/// For durable storage, implement [CounterStorage] with a backend of your
/// choice (e.g. `shared_preferences` or `hive`) and pass it to
/// `CounterTrackerService.configure(storage: ...)`. See the README for
/// ready-to-copy adapters.
class MemoryCounterStorage implements CounterStorage {
  final Map<String, CounterData> _store = <String, CounterData>{};

  @override
  Future<void> init() async {}

  @override
  Future<CounterData> getCounter(String id) async =>
      _store[id] ?? CounterData.empty(id);

  @override
  Future<int> getViews(String id) async => (await getCounter(id)).views;

  @override
  Future<int> getClicks(String id) async => (await getCounter(id)).clicks;

  @override
  Future<CounterData> incrementView(String id) async {
    final current = await getCounter(id);
    final updated = current.copyWith(
      views: current.views + 1,
      lastViewedAt: DateTime.now(),
    );
    _store[id] = updated;
    return updated;
  }

  @override
  Future<CounterData> incrementClick(String id) async {
    final current = await getCounter(id);
    final updated = current.copyWith(
      clicks: current.clicks + 1,
      lastClickedAt: DateTime.now(),
    );
    _store[id] = updated;
    return updated;
  }

  @override
  Future<Map<String, CounterData>> getAll() async =>
      Map<String, CounterData>.from(_store);

  @override
  Future<void> clear() async => _store.clear();
}
