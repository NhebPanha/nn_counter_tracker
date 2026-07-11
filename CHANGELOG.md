# Changelog

All notable changes to this project are documented here. This project adheres
to [Semantic Versioning](https://semver.org).

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
