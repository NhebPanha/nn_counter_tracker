import 'package:flutter/widgets.dart';

import '../services/counter_tracker_service.dart';

/// Wraps [child] and records a *click* every time it is tapped.
///
/// ```dart
/// CounterClickTracker(
///   id: 'product_001',
///   onClicked: (count) => debugPrint('Clicked: $count'),
///   child: ProductCard(),
/// )
/// ```
class CounterClickTracker extends StatelessWidget {
  /// Creates a click tracker for [id] wrapping [child].
  const CounterClickTracker({
    super.key,
    required this.id,
    required this.child,
    this.onClicked,
    this.onTap,
    this.behavior = HitTestBehavior.opaque,
    this.service,
  });

  /// Identifier under which the click is recorded.
  final String id;

  /// The tappable widget.
  final Widget child;

  /// Called with the new total click count after a click is recorded.
  final ValueChanged<int>? onClicked;

  /// Additional tap callback forwarded from the underlying [GestureDetector].
  final VoidCallback? onTap;

  /// How the underlying [GestureDetector] behaves during hit testing.
  final HitTestBehavior behavior;

  /// Service used to record the click. Defaults to the shared singleton.
  final CounterTrackerService? service;

  CounterTrackerService get _service =>
      service ?? CounterTrackerService.instance;

  void _handleTap() {
    onTap?.call();
    _service.incrementClick(id).then((data) => onClicked?.call(data.clicks));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: _handleTap,
      child: child,
    );
  }
}
