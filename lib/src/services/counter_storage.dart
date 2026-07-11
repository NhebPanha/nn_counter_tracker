import '../models/counter_data.dart';

/// Persistence contract for counter data.
///
/// Implementations are responsible for durably storing the view/click counts
/// for each tracked [String] id. The package ships with a
/// `SharedPreferencesCounterStorage` (default) and a `HiveCounterStorage`
/// implementation, but you may provide your own (e.g. a remote/back-end store).
abstract class CounterStorage {
  /// Performs any asynchronous setup required before the store can be used.
  ///
  /// Safe to call multiple times; implementations should be idempotent.
  Future<void> init() async {}

  /// Atomically increments the view counter for [id] and returns the resulting
  /// [CounterData].
  Future<CounterData> incrementView(String id);

  /// Atomically increments the click counter for [id] and returns the resulting
  /// [CounterData].
  Future<CounterData> incrementClick(String id);

  /// Returns the current number of views recorded for [id] (0 if unknown).
  Future<int> getViews(String id);

  /// Returns the current number of clicks recorded for [id] (0 if unknown).
  Future<int> getClicks(String id);

  /// Returns the full [CounterData] for [id], or an empty record if unknown.
  Future<CounterData> getCounter(String id);

  /// Returns every stored [CounterData] keyed by its id.
  Future<Map<String, CounterData>> getAll();

  /// Removes all stored counters.
  Future<void> clear();
}
