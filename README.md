# nn_counter_tracker

Lightweight, highly customizable **analytics-style tracking** for Flutter
widgets — count views, impressions, taps, clicks and user interactions. It works
like a mini analytics SDK while staying simple and developer-friendly.

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Track any of the following out of the box:

- Widget views & impressions
- Button clicks
- Card taps
- Banner interactions
- Coupon interactions
- Product views
- Promotion clicks

## Supported platforms

| Android | iOS | Web | macOS | Windows | Linux |
| :-----: | :-: | :-: | :---: | :-----: | :---: |
|   ✅    | ✅  | ✅  |  ✅   |   ✅    |  ✅   |

## Features

- 👀 **View tracking** with `VisibilityDetector`, a configurable visibility
  threshold, duplicate-suppression and an optional cooldown.
- 👆 **Click tracking** with tap detection and count callbacks.
- 🔗 **Combined tracker** for views + clicks in one widget.
- 🧱 **Pluggable storage** — `SharedPreferences` (default) or `Hive`, or bring
  your own by implementing `CounterStorage`.
- 🔔 **Reactive** — per-id `ValueListenable`s and a broadcast `updates` stream.
  No external state-management packages required.
- 📊 **Analytics API** to read counters anywhere.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  nn_counter_tracker: ^0.1.0
```

Then run:

```bash
flutter pub get
```

Optionally initialize the service at start-up (needed for logs / custom
storage):

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CounterTrackerService.instance.configure(enableLogs: true);
  await CounterTrackerService.instance.init();
  runApp(const MyApp());
}
```

## Usage

### View tracking

Counts a view when the widget becomes visible.

```dart
CounterViewTracker(
  id: 'product_001',
  visibilityThreshold: 0.5,
  cooldownDuration: Duration(seconds: 3),
  onViewed: (count) => debugPrint('Viewed: $count'),
  child: ProductCard(),
)
```

### Click tracking

```dart
CounterClickTracker(
  id: 'product_001',
  onClicked: (count) => debugPrint('Clicked: $count'),
  child: ProductCard(),
)
```

### Combined tracker

```dart
CounterTracker(
  id: 'promo_001',
  trackView: true,
  trackClick: true,
  child: PromotionCard(),
)
```

### Reactive UI with `CounterBuilder`

```dart
CounterBuilder(
  id: 'product_001',
  builder: (context, data, _) => Text(
    'Views: ${data.views} | Clicks: ${data.clicks}',
  ),
)
```

### Analytics API

```dart
final counter = await CounterAnalytics.getCounter('product_001');
final views   = await CounterAnalytics.getViews('product_001');
final clicks  = await CounterAnalytics.getClicks('product_001');
final all     = await CounterAnalytics.getAllCounters();
await CounterAnalytics.clear();
```

## Customization

| Option                | Type        | Applies to                | Default |
| --------------------- | ----------- | ------------------------- | ------- |
| `visibilityThreshold` | `double`    | view / combined trackers  | `0.5`   |
| `cooldownDuration`    | `Duration?` | view / combined trackers  | `null`  |
| `enableLogs`          | `bool`      | service (`configure`)     | `false` |
| `trackView`           | `bool`      | `CounterTracker`          | `true`  |
| `trackClick`          | `bool`      | `CounterTracker`          | `true`  |

## Choosing a storage backend

`SharedPreferences` is used by default. To use Hive:

```dart
import 'package:hive/hive.dart';

Hive.init(directory); // or Hive.initFlutter();
CounterTrackerService.instance.configure(
  storage: HiveCounterStorage(),
);
```

Implement `CounterStorage` for a custom (e.g. remote) backend.

## Architecture

```text
Widgets  ──▶  CounterTrackerService  ──▶  CounterStorage
(view/click)   (cache + notifiers +        (SharedPreferences /
               broadcast stream)            Hive / custom)
```

## API reference

Public classes: `CounterData`, `CounterStorage`,
`SharedPreferencesCounterStorage`, `HiveCounterStorage`,
`CounterTrackerService`, `CounterAnalytics`, `CounterLogger`,
`CounterViewTracker`, `CounterClickTracker`, `CounterTracker`, `CounterBuilder`.
See the inline dartdoc for each member.

## Screenshots

> Add screenshots/GIFs of the example app here. Run the example with
> `cd example && flutter run`.

| Feed | Dashboard |
| ---- | --------- |
| _(screenshot)_ | _(screenshot)_ |

## Example

A full example lives in [`example/`](example/), demonstrating product cards,
promotion banners, coupon cards, view + click tracking and an analytics
dashboard.

## Contributing

Issues and PRs are welcome. Please run `flutter analyze` and `flutter test`
before submitting.

## License

[MIT](LICENSE)
