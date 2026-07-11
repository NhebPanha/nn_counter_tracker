import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/counter_data.dart';
import '../services/counter_storage.dart';

/// Default [CounterStorage] backed by `shared_preferences`.
///
/// Every counter is serialized to JSON and stored under a namespaced key
/// (`<keyPrefix><id>`). A single index key tracks all known ids so that
/// [getAll] and [clear] can operate without scanning unrelated preferences.
class SharedPreferencesCounterStorage implements CounterStorage {
  /// Creates a shared-preferences backed store.
  ///
  /// Pass an existing [preferences] instance to reuse it (useful for testing);
  /// otherwise one is obtained lazily in [init].
  SharedPreferencesCounterStorage({
    SharedPreferences? preferences,
    this.keyPrefix = 'nn_counter_tracker.',
  }) : _prefs = preferences;

  /// Prefix applied to every persisted key to avoid collisions.
  final String keyPrefix;

  SharedPreferences? _prefs;

  String get _indexKey => '${keyPrefix}__index__';

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _prefsInstance async {
    await init();
    return _prefs!;
  }

  String _dataKey(String id) => '$keyPrefix$id';

  @override
  Future<CounterData> getCounter(String id) async {
    final prefs = await _prefsInstance;
    final raw = prefs.getString(_dataKey(id));
    if (raw == null) return CounterData.empty(id);
    try {
      return CounterData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return CounterData.empty(id);
    }
  }

  @override
  Future<int> getViews(String id) async => (await getCounter(id)).views;

  @override
  Future<int> getClicks(String id) async => (await getCounter(id)).clicks;

  Future<CounterData> _save(SharedPreferences prefs, CounterData data) async {
    await prefs.setString(_dataKey(data.id), jsonEncode(data.toJson()));
    await _addToIndex(prefs, data.id);
    return data;
  }

  @override
  Future<CounterData> incrementView(String id) async {
    final prefs = await _prefsInstance;
    final current = await getCounter(id);
    final updated = current.copyWith(
      views: current.views + 1,
      lastViewedAt: DateTime.now(),
    );
    return _save(prefs, updated);
  }

  @override
  Future<CounterData> incrementClick(String id) async {
    final prefs = await _prefsInstance;
    final current = await getCounter(id);
    final updated = current.copyWith(
      clicks: current.clicks + 1,
      lastClickedAt: DateTime.now(),
    );
    return _save(prefs, updated);
  }

  @override
  Future<Map<String, CounterData>> getAll() async {
    final prefs = await _prefsInstance;
    final ids = prefs.getStringList(_indexKey) ?? const <String>[];
    final result = <String, CounterData>{};
    for (final id in ids) {
      result[id] = await getCounter(id);
    }
    return result;
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefsInstance;
    final ids = prefs.getStringList(_indexKey) ?? const <String>[];
    for (final id in ids) {
      await prefs.remove(_dataKey(id));
    }
    await prefs.remove(_indexKey);
  }

  Future<void> _addToIndex(SharedPreferences prefs, String id) async {
    final ids = prefs.getStringList(_indexKey) ?? <String>[];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_indexKey, ids);
    }
  }
}
