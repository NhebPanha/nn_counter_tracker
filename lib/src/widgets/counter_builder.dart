import 'package:flutter/widgets.dart';

import '../models/counter_data.dart';
import '../services/counter_tracker_service.dart';

/// Rebuilds [builder] whenever the counters for [id] change.
///
/// Backed by the service's per-id [ValueListenable], so it updates live as
/// views and clicks are recorded anywhere in the app.
///
/// ```dart
/// CounterBuilder(
///   id: 'product_001',
///   builder: (context, data) => Text(
///     'Views: ${data.views} | Clicks: ${data.clicks}',
///   ),
/// )
/// ```
class CounterBuilder extends StatelessWidget {
  /// Creates a builder that reacts to changes for [id].
  const CounterBuilder({
    super.key,
    required this.id,
    required this.builder,
    this.child,
    this.service,
  });

  /// Identifier whose counters are observed.
  final String id;

  /// Builds a widget from the latest [CounterData].
  ///
  /// [child] is passed through unchanged for optimization of subtrees that do
  /// not depend on the counter value.
  final Widget Function(BuildContext context, CounterData data, Widget? child)
      builder;

  /// An optional child forwarded to [builder] unchanged on every rebuild.
  final Widget? child;

  /// Service to observe. Defaults to the shared singleton.
  final CounterTrackerService? service;

  @override
  Widget build(BuildContext context) {
    final svc = service ?? CounterTrackerService.instance;
    return ValueListenableBuilder<CounterData>(
      valueListenable: svc.listenable(id),
      builder: (context, data, child) => builder(context, data, child),
      child: child,
    );
  }
}
