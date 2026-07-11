Create a production-ready Flutter package called **nn_counter_tracker** that provides analytics-style tracking for widget views, impressions, taps, clicks, and user interactions.

## Goal

Build a lightweight, highly customizable Flutter package that allows developers to track:

* Widget views
* Widget impressions
* Button clicks
* Card taps
* Banner interactions
* Coupon interactions
* Product views
* Promotion clicks

The package should work similarly to a mini analytics SDK but remain simple and developer-friendly.

---

## Package Name

nn_counter_tracker

---

## Supported Platforms

* Android
* iOS
* Web
* macOS
* Windows
* Linux

---

## Features

### View Tracking

Automatically count a view when a widget becomes visible on screen.

Example:

```dart
CounterViewTracker(
  id: 'product_001',
  child: ProductCard(),
)
```

Requirements:

* Use VisibilityDetector
* Configurable visibility threshold
* Prevent duplicate counting while visible
* Optional cooldown duration

---

### Click Tracking

Track user interactions.

Example:

```dart
CounterClickTracker(
  id: 'product_001',
  child: ProductCard(),
)
```

Requirements:

* Detect tap gestures
* Count clicks
* Expose callback

Example:

```dart
onClicked: (count) {
  debugPrint('Clicked: $count');
}
```

---

### Combined Tracker

Example:

```dart
CounterTracker(
  id: 'promo_001',
  trackView: true,
  trackClick: true,
  child: PromotionCard(),
)
```

---

## Data Model

Create:

```dart
class CounterData {
  final String id;
  final int views;
  final int clicks;
  final DateTime? lastViewedAt;
  final DateTime? lastClickedAt;
}
```

Include:

* fromJson
* toJson
* copyWith
* equality support

---

## Storage Layer

Create abstract storage interface:

```dart
abstract class CounterStorage {
  Future<void> incrementView(String id);
  Future<void> incrementClick(String id);

  Future<int> getViews(String id);
  Future<int> getClicks(String id);

  Future<void> clear();
}
```

Implement:

### SharedPreferencesCounterStorage

Default storage implementation.

### HiveCounterStorage

Optional implementation.

---

## Service Layer

Create:

```dart
CounterTrackerService
```

Responsibilities:

* Increment counters
* Read counters
* Cache values
* Notify listeners
* Stream updates

---

## State Management

Use:

* ValueNotifier
* StreamController

No external state management packages.

---

## Widgets

### CounterViewTracker

### CounterClickTracker

### CounterTracker

### CounterBuilder

Example:

```dart
CounterBuilder(
  id: 'product_001',
  builder: (context, data) {
    return Text(
      'Views: ${data.views} | Clicks: ${data.clicks}',
    );
  },
)
```

---

## Analytics API

Provide methods:

```dart
CounterAnalytics.getCounter(id);

CounterAnalytics.getViews(id);

CounterAnalytics.getClicks(id);

CounterAnalytics.getAllCounters();

CounterAnalytics.clear();
```

---

## Customization

Support:

```dart
visibilityThreshold: 0.5

cooldownDuration: Duration(seconds: 3)

enableLogs: true

trackView: true

trackClick: true
```

---

## Folder Structure

```text
lib/
├── nn_counter_tracker.dart
│
├── src/
│   ├── models/
│   │   └── counter_data.dart
│   │
│   ├── services/
│   │   ├── counter_tracker_service.dart
│   │   └── counter_storage.dart
│   │
│   ├── storage/
│   │   ├── shared_preferences_storage.dart
│   │   └── hive_storage.dart
│   │
│   ├── widgets/
│   │   ├── counter_view_tracker.dart
│   │   ├── counter_click_tracker.dart
│   │   ├── counter_tracker.dart
│   │   └── counter_builder.dart
│   │
│   └── utils/
│       └── logger.dart
│
example/
test/
```

---

## Example Application

Build a complete example app showing:

* Product cards
* Promotion banners
* Coupon cards
* Click tracking
* View tracking
* Analytics dashboard

---

## Documentation

Generate:

* README.md
* Installation guide
* API reference
* Usage examples
* Screenshots section
* Changelog
* MIT License

---

## Code Quality

Requirements:

* Flutter 3.29+
* Dart 3+
* Null Safety
* Lints enabled
* Unit tests
* Widget tests
* Production-ready architecture
* Pub.dev score optimized
* Well documented public APIs

Generate the complete package source code, example app, tests, README, pubspec.yaml, and all required files.
