import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../services/counter_tracker_service.dart';

/// Wraps [child] and records a *view* when it becomes sufficiently visible.
///
/// Visibility is measured with [VisibilityDetector]. A view is counted once the
/// visible fraction reaches [visibilityThreshold]. To avoid inflating counts
/// while the widget merely stays on screen, a new view is not recorded again
/// until the widget has left the screen and, optionally, a [cooldownDuration]
/// has elapsed since the last recorded view.
///
/// ```dart
/// CounterViewTracker(
///   id: 'product_001',
///   child: ProductCard(),
/// )
/// ```
class CounterViewTracker extends StatefulWidget {
  /// Creates a view tracker for [id] wrapping [child].
  const CounterViewTracker({
    super.key,
    required this.id,
    required this.child,
    this.visibilityThreshold = 0.5,
    this.cooldownDuration,
    this.onViewed,
    this.service,
  }) : assert(
          visibilityThreshold >= 0 && visibilityThreshold <= 1,
          'visibilityThreshold must be between 0 and 1',
        );

  /// Identifier under which the view is recorded.
  final String id;

  /// The widget whose visibility is tracked.
  final Widget child;

  /// Fraction of the widget (0–1) that must be visible to count a view.
  final double visibilityThreshold;

  /// Minimum time between two recorded views for the same [id].
  ///
  /// When `null`, a new view is recorded every time the widget re-enters the
  /// screen after leaving it.
  final Duration? cooldownDuration;

  /// Called with the new total view count after a view is recorded.
  final ValueChanged<int>? onViewed;

  /// Service used to record the view. Defaults to the shared singleton.
  final CounterTrackerService? service;

  @override
  State<CounterViewTracker> createState() => _CounterViewTrackerState();
}

class _CounterViewTrackerState extends State<CounterViewTracker> {
  bool _visible = false;
  DateTime? _lastViewedAt;

  CounterTrackerService get _service =>
      widget.service ?? CounterTrackerService.instance;

  void _onVisibilityChanged(VisibilityInfo info) {
    final isVisible = info.visibleFraction >= widget.visibilityThreshold;
    if (isVisible && !_visible) {
      _visible = true;
      _maybeCount();
    } else if (!isVisible && _visible) {
      _visible = false;
    }
  }

  void _maybeCount() {
    final cooldown = widget.cooldownDuration;
    if (cooldown != null && _lastViewedAt != null) {
      final elapsed = DateTime.now().difference(_lastViewedAt!);
      if (elapsed < cooldown) return;
    }
    _lastViewedAt = DateTime.now();
    _service.incrementView(widget.id).then((data) {
      if (mounted) widget.onViewed?.call(data.views);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('nn_counter_view_${widget.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }
}
