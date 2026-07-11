import 'package:flutter/widgets.dart';

import '../services/counter_tracker_service.dart';
import 'counter_click_tracker.dart';
import 'counter_view_tracker.dart';

/// Combined view + click tracker.
///
/// Composes [CounterViewTracker] and [CounterClickTracker] so a single widget
/// can record both impressions and taps for the same [id]. Enable either
/// dimension with [trackView] / [trackClick].
///
/// ```dart
/// CounterTracker(
///   id: 'promo_001',
///   trackView: true,
///   trackClick: true,
///   child: PromotionCard(),
/// )
/// ```
class CounterTracker extends StatelessWidget {
  /// Creates a combined tracker for [id] wrapping [child].
  const CounterTracker({
    super.key,
    required this.id,
    required this.child,
    this.trackView = true,
    this.trackClick = true,
    this.visibilityThreshold = 0.5,
    this.cooldownDuration,
    this.onViewed,
    this.onClicked,
    this.onTap,
    this.service,
  });

  /// Identifier under which views/clicks are recorded.
  final String id;

  /// The wrapped widget.
  final Widget child;

  /// Whether visibility-based view tracking is enabled.
  final bool trackView;

  /// Whether tap-based click tracking is enabled.
  final bool trackClick;

  /// Fraction of the widget (0–1) that must be visible to count a view.
  final double visibilityThreshold;

  /// Minimum time between two recorded views for the same [id].
  final Duration? cooldownDuration;

  /// Called with the new total view count after a view is recorded.
  final ValueChanged<int>? onViewed;

  /// Called with the new total click count after a click is recorded.
  final ValueChanged<int>? onClicked;

  /// Additional tap callback.
  final VoidCallback? onTap;

  /// Service used to record events. Defaults to the shared singleton.
  final CounterTrackerService? service;

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (trackClick) {
      current = CounterClickTracker(
        id: id,
        onClicked: onClicked,
        onTap: onTap,
        service: service,
        child: current,
      );
    }

    if (trackView) {
      current = CounterViewTracker(
        id: id,
        visibilityThreshold: visibilityThreshold,
        cooldownDuration: cooldownDuration,
        onViewed: onViewed,
        service: service,
        child: current,
      );
    }

    return current;
  }
}
