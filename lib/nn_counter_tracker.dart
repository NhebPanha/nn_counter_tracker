/// Analytics-style tracking for widget views, impressions, taps, and clicks.
///
/// `nn_counter_tracker` is a lightweight, customizable Flutter package that
/// works like a mini analytics SDK while staying simple and developer-friendly.
///
/// Quick start:
///
/// ```dart
/// import 'package:nn_counter_tracker/nn_counter_tracker.dart';
///
/// CounterTracker(
///   id: 'promo_001',
///   trackView: true,
///   trackClick: true,
///   child: PromotionCard(),
/// );
///
/// final data = await CounterAnalytics.getCounter('promo_001');
/// ```
library;

// Models
export 'src/models/counter_data.dart';

// Services & analytics
export 'src/services/counter_analytics.dart';
export 'src/services/counter_storage.dart';
export 'src/services/counter_tracker_service.dart';

// Storage implementations
export 'src/storage/hive_storage.dart';
export 'src/storage/shared_preferences_storage.dart';

// Utils
export 'src/utils/logger.dart';

// Widgets
export 'src/widgets/counter_builder.dart';
export 'src/widgets/counter_click_tracker.dart';
export 'src/widgets/counter_tracker.dart';
export 'src/widgets/counter_view_tracker.dart';
