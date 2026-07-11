import '../models/counter_data.dart';
import 'counter_tracker_service.dart';

/// Static, convenience facade over [CounterTrackerService].
///
/// Provides a terse, discoverable API for reading counters without holding a
/// reference to the service singleton:
///
/// ```dart
/// final data = await CounterAnalytics.getCounter('product_001');
/// final views = await CounterAnalytics.getViews('product_001');
/// ```
abstract final class CounterAnalytics {
  static CounterTrackerService get _service => CounterTrackerService.instance;

  /// Returns the full [CounterData] for [id].
  static Future<CounterData> getCounter(String id) => _service.getCounter(id);

  /// Returns the number of views recorded for [id].
  static Future<int> getViews(String id) => _service.getViews(id);

  /// Returns the number of clicks recorded for [id].
  static Future<int> getClicks(String id) => _service.getClicks(id);

  /// Returns every stored counter keyed by id.
  static Future<Map<String, CounterData>> getAllCounters() =>
      _service.getAllCounters();

  /// Records a view for [id]. Rarely needed directly — prefer the widgets.
  static Future<CounterData> trackView(String id) => _service.incrementView(id);

  /// Records a click for [id]. Rarely needed directly — prefer the widgets.
  static Future<CounterData> trackClick(String id) =>
      _service.incrementClick(id);

  /// A broadcast stream of counter updates.
  static Stream<CounterData> get updates => _service.updates;

  /// Clears all stored counters.
  static Future<void> clear() => _service.clear();
}
