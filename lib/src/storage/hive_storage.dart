import 'package:hive/hive.dart';

import '../models/counter_data.dart';
import '../services/counter_storage.dart';

/// Optional [CounterStorage] backed by [Hive].
///
/// Counters are stored as JSON maps in a dedicated box. This implementation is
/// well suited to apps that already depend on Hive or that need higher write
/// throughput than `shared_preferences` provides.
///
/// You are responsible for calling `Hive.init`/`Hive.initFlutter` before use;
/// [init] only opens the box.
class HiveCounterStorage implements CounterStorage {
  /// Creates a Hive-backed store using the box named [boxName].
  HiveCounterStorage({this.boxName = 'nn_counter_tracker'});

  /// The name of the Hive box used for persistence.
  final String boxName;

  Box<Map<dynamic, dynamic>>? _box;

  @override
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = Hive.isBoxOpen(boxName)
        ? Hive.box<Map<dynamic, dynamic>>(boxName)
        : await Hive.openBox<Map<dynamic, dynamic>>(boxName);
  }

  Future<Box<Map<dynamic, dynamic>>> get _boxInstance async {
    await init();
    return _box!;
  }

  @override
  Future<CounterData> getCounter(String id) async {
    final box = await _boxInstance;
    final raw = box.get(id);
    if (raw == null) return CounterData.empty(id);
    return CounterData.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<int> getViews(String id) async => (await getCounter(id)).views;

  @override
  Future<int> getClicks(String id) async => (await getCounter(id)).clicks;

  @override
  Future<CounterData> incrementView(String id) async {
    final box = await _boxInstance;
    final current = await getCounter(id);
    final updated = current.copyWith(
      views: current.views + 1,
      lastViewedAt: DateTime.now(),
    );
    await box.put(id, updated.toJson());
    return updated;
  }

  @override
  Future<CounterData> incrementClick(String id) async {
    final box = await _boxInstance;
    final current = await getCounter(id);
    final updated = current.copyWith(
      clicks: current.clicks + 1,
      lastClickedAt: DateTime.now(),
    );
    await box.put(id, updated.toJson());
    return updated;
  }

  @override
  Future<Map<String, CounterData>> getAll() async {
    final box = await _boxInstance;
    final result = <String, CounterData>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        result['$key'] = CounterData.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    return result;
  }

  @override
  Future<void> clear() async {
    final box = await _boxInstance;
    await box.clear();
  }
}
