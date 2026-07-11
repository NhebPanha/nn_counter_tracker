import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/counter_data.dart';
import '../storage/shared_preferences_storage.dart';
import '../utils/logger.dart';
import 'counter_storage.dart';

/// Central coordinator that increments, caches, and broadcasts counter values.
///
/// The service is a singleton accessed through [CounterTrackerService.instance].
/// It owns a [CounterStorage] (defaulting to `SharedPreferencesCounterStorage`),
/// keeps an in-memory cache for synchronous reads, and exposes per-id
/// [ValueListenable]s plus a global [updates] stream so widgets can react to
/// changes without external state-management packages.
///
/// Call [configure] once during app start-up if you want a non-default storage
/// backend or logging enabled.
class CounterTrackerService {
  CounterTrackerService._();

  /// The shared singleton instance.
  static final CounterTrackerService instance = CounterTrackerService._();

  CounterStorage _storage = SharedPreferencesCounterStorage();
  CounterLogger _logger = const CounterLogger();
  bool _initialized = false;

  final Map<String, ValueNotifier<CounterData>> _notifiers =
      <String, ValueNotifier<CounterData>>{};
  final StreamController<CounterData> _controller =
      StreamController<CounterData>.broadcast();

  /// A broadcast stream that emits the latest [CounterData] after every change.
  Stream<CounterData> get updates => _controller.stream;

  /// Whether [init] has completed.
  bool get isInitialized => _initialized;

  /// Overrides the [storage] backend and/or toggles [enableLogs].
  ///
  /// Must be called before the first tracking call for the new storage to take
  /// effect. Re-configuring resets the initialization flag so the new backend
  /// is set up on next use.
  void configure({CounterStorage? storage, bool? enableLogs}) {
    if (storage != null) {
      _storage = storage;
      _initialized = false;
    }
    if (enableLogs != null) {
      _logger = _logger.copyWith(enabled: enableLogs);
    }
  }

  /// Initializes the underlying storage. Idempotent.
  Future<void> init() async {
    if (_initialized) return;
    await _storage.init();
    _initialized = true;
    _logger.log('initialized with ${_storage.runtimeType}');
  }

  /// Returns (creating if needed) the [ValueListenable] for [id].
  ///
  /// The listenable starts with the cached value or an empty record, then is
  /// hydrated asynchronously from storage.
  ValueListenable<CounterData> listenable(String id) {
    return _notifierFor(id);
  }

  ValueNotifier<CounterData> _notifierFor(String id) {
    return _notifiers.putIfAbsent(id, () {
      final notifier = ValueNotifier<CounterData>(CounterData.empty(id));
      // Hydrate from storage in the background.
      unawaited(_hydrate(id, notifier));
      return notifier;
    });
  }

  Future<void> _hydrate(String id, ValueNotifier<CounterData> notifier) async {
    try {
      await init();
      final data = await _storage.getCounter(id);
      notifier.value = data;
    } catch (e, s) {
      _logger.error('failed to hydrate $id', e, s);
    }
  }

  void _publish(CounterData data) {
    _notifierFor(data.id).value = data;
    if (!_controller.isClosed) _controller.add(data);
  }

  /// Records a view for [id], persists it, and notifies listeners.
  Future<CounterData> incrementView(String id) async {
    await init();
    final data = await _storage.incrementView(id);
    _logger.log('view($id) -> ${data.views}');
    _publish(data);
    return data;
  }

  /// Records a click for [id], persists it, and notifies listeners.
  Future<CounterData> incrementClick(String id) async {
    await init();
    final data = await _storage.incrementClick(id);
    _logger.log('click($id) -> ${data.clicks}');
    _publish(data);
    return data;
  }

  /// Returns the full [CounterData] for [id].
  Future<CounterData> getCounter(String id) async {
    await init();
    final data = await _storage.getCounter(id);
    _notifierFor(id).value = data;
    return data;
  }

  /// Returns the number of views recorded for [id].
  Future<int> getViews(String id) async {
    await init();
    return _storage.getViews(id);
  }

  /// Returns the number of clicks recorded for [id].
  Future<int> getClicks(String id) async {
    await init();
    return _storage.getClicks(id);
  }

  /// Returns every stored counter keyed by id.
  Future<Map<String, CounterData>> getAllCounters() async {
    await init();
    return _storage.getAll();
  }

  /// Clears all counters from storage and resets in-memory notifiers to empty.
  Future<void> clear() async {
    await init();
    await _storage.clear();
    for (final entry in _notifiers.entries) {
      entry.value.value = CounterData.empty(entry.key);
    }
    _logger.log('cleared all counters');
  }

  /// Disposes stream/notifier resources. Primarily used in tests.
  @visibleForTesting
  Future<void> dispose() async {
    for (final n in _notifiers.values) {
      n.dispose();
    }
    _notifiers.clear();
    await _controller.close();
  }
}
