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
- 🧱 **Plugin-free core** — a pure-Dart in-memory store by default (no native
  plugins, builds everywhere including Windows without Developer Mode). Add
  persistence by implementing `CounterStorage` (adapters below).
- 🔔 **Reactive** — per-id `ValueListenable`s and a broadcast `updates` stream.
  No external state-management packages required.
- 📊 **Analytics API** to read counters anywhere.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  nn_counter_tracker: ^0.2.0
```

Requires **Dart 3.0+ / Flutter 3.0+**. The package has no native plugin
dependencies, so it builds on Android, iOS, Web, macOS, Windows and Linux with
no extra setup.

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

## Storage backends

By default the service uses the plugin-free `MemoryCounterStorage`, which keeps
counters in memory for the lifetime of the process. This keeps the core package
free of native plugins so it builds everywhere with no extra setup.

To persist counters, implement `CounterStorage` and pass it to `configure`:

```dart
CounterTrackerService.instance.configure(
  storage: MySharedPreferencesStorage(),
);
```

### Optional: `shared_preferences` adapter

Add `shared_preferences` to *your app's* `pubspec.yaml`, then drop this adapter
in. (On Windows, running an app that uses a native plugin such as
`shared_preferences` requires enabling Developer Mode — run
`start ms-settings:developers`.)

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

class SharedPreferencesCounterStorage implements CounterStorage {
  SharedPreferencesCounterStorage({this.keyPrefix = 'nn_counter_tracker.'});
  final String keyPrefix;
  SharedPreferences? _prefs;

  String get _indexKey => '${keyPrefix}__index__';
  String _dataKey(String id) => '$keyPrefix$id';

  @override
  Future<void> init() async => _prefs ??= await SharedPreferences.getInstance();

  Future<SharedPreferences> get _p async {
    await init();
    return _prefs!;
  }

  @override
  Future<CounterData> getCounter(String id) async {
    final raw = (await _p).getString(_dataKey(id));
    if (raw == null) return CounterData.empty(id);
    return CounterData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<int> getViews(String id) async => (await getCounter(id)).views;

  @override
  Future<int> getClicks(String id) async => (await getCounter(id)).clicks;

  Future<CounterData> _save(CounterData d) async {
    final prefs = await _p;
    await prefs.setString(_dataKey(d.id), jsonEncode(d.toJson()));
    final ids = prefs.getStringList(_indexKey) ?? <String>[];
    if (!ids.contains(d.id)) {
      await prefs.setStringList(_indexKey, ids..add(d.id));
    }
    return d;
  }

  @override
  Future<CounterData> incrementView(String id) async {
    final c = await getCounter(id);
    return _save(c.copyWith(views: c.views + 1, lastViewedAt: DateTime.now()));
  }

  @override
  Future<CounterData> incrementClick(String id) async {
    final c = await getCounter(id);
    return _save(c.copyWith(clicks: c.clicks + 1, lastClickedAt: DateTime.now()));
  }

  @override
  Future<Map<String, CounterData>> getAll() async {
    final prefs = await _p;
    final ids = prefs.getStringList(_indexKey) ?? const <String>[];
    return {for (final id in ids) id: await getCounter(id)};
  }

  @override
  Future<void> clear() async {
    final prefs = await _p;
    for (final id in prefs.getStringList(_indexKey) ?? const <String>[]) {
      await prefs.remove(_dataKey(id));
    }
    await prefs.remove(_indexKey);
  }
}
```

The same pattern works for Hive or any remote backend — implement the five
`CounterStorage` methods and you're done.

## Architecture

```text
Widgets  ──▶  CounterTrackerService  ──▶  CounterStorage
(view/click)   (cache + notifiers +        (MemoryCounterStorage default,
               broadcast stream)            or your persistent adapter)
```

## API reference

Public classes: `CounterData`, `CounterStorage`, `MemoryCounterStorage`,
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
