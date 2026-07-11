# Changelog

All notable changes to this project are documented here. This project adheres
to [Semantic Versioning](https://semver.org).

## 0.2.0

### Changed
- **Plugin-free core.** The default storage is now the pure-Dart
  `MemoryCounterStorage`, and the package no longer depends on
  `shared_preferences` or `hive`. This lets the package (and apps consuming it)
  build on every platform — including Windows without Developer Mode — with no
  native-plugin symlink requirement.
- **Lowered SDK constraints** to Dart `>=3.0.0` and Flutter `>=3.0.0`.

### Removed
- `SharedPreferencesCounterStorage` and `HiveCounterStorage` are no longer
  bundled (they pulled in native plugins). Ready-to-copy adapters are documented
  in the README for apps that want persistence.

### Migration
- Zero-config usage is unchanged. For persistence, add `shared_preferences` (or
  your backend) to your app and pass a `CounterStorage` to
  `CounterTrackerService.configure(storage: ...)` — see the README.

## 0.1.0

Initial release.

### Added
- `CounterData` immutable model with `fromJson`/`toJson`/`copyWith`/equality.
- `CounterStorage` abstraction with two implementations:
  - `SharedPreferencesCounterStorage` (default).
  - `HiveCounterStorage` (optional).
- `CounterTrackerService` singleton with in-memory caching, per-id
  `ValueListenable`s and a broadcast `updates` stream.
- `CounterAnalytics` static facade (`getCounter`, `getViews`, `getClicks`,
  `getAllCounters`, `clear`).
- Widgets: `CounterViewTracker`, `CounterClickTracker`, `CounterTracker`,
  `CounterBuilder`.
- Configurable `visibilityThreshold`, `cooldownDuration`, `enableLogs`,
  `trackView`, `trackClick`.
- Example app with product cards, promotions, coupons, banners and an analytics
  dashboard.
- Unit and widget tests.
