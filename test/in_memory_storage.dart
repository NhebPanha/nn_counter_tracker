import 'package:nn_counter_tracker/nn_counter_tracker.dart';

/// Simple in-memory [CounterStorage] used to make tests deterministic and
/// independent of platform channels.
class InMemoryCounterStorage implements CounterStorage {
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
