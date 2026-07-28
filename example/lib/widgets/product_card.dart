import 'package:flutter/material.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

import '../data/demo_products.dart';
import 'stat_chip.dart';

/// A product tile that automatically tracks both **views** and **clicks**.
///
/// The whole card is wrapped in a [CounterTracker]:
/// * a *view* is recorded once the card is at least half visible on screen
///   (with a short cooldown to avoid double-counting while it stays in view);
/// * a *click* is recorded every time the user taps the card.
///
/// A nested [CounterBuilder] shows the live counts, updating instantly whenever
/// either counter changes anywhere in the app.
class ProductCard extends StatelessWidget {
  /// Creates a tracked product card.
  const ProductCard({super.key, required this.product, this.onTap});

  /// The product to display and track.
  final Product product;

  /// Optional extra tap handler (e.g. navigate to a detail page).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CounterTracker(
      id: product.id,
      trackView: true,
      trackClick: true,
      visibilityThreshold: 0.5,
      cooldownDuration: const Duration(seconds: 2),
      onTap: onTap,
      onViewed: (count) => debugPrint('view  ${product.id} -> $count'),
      onClicked: (count) => debugPrint('click ${product.id} -> $count'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CircleAvatar(radius: 28, child: Icon(product.icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (product.tag != null) _TagBadge(label: product.tag!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(product.price, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    CounterBuilder(
                      id: product.id,
                      builder: (context, data, _) => Row(
                        children: <Widget>[
                          StatChip(
                            icon: Icons.visibility_outlined,
                            value: data.views,
                            label: 'views',
                          ),
                          const SizedBox(width: 8),
                          StatChip(
                            icon: Icons.touch_app_outlined,
                            value: data.clicks,
                            label: 'clicks',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
