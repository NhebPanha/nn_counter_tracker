import 'package:flutter/material.dart';

/// A compact icon + value pill used to display a single counter (views/clicks).
class StatChip extends StatelessWidget {
  /// Creates a stat chip.
  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  /// Leading icon.
  final IconData icon;

  /// The numeric value to display.
  final int value;

  /// Accessible/tooltip label describing the value.
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '$value $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: scheme.primary),
            const SizedBox(width: 5),
            Text('$value', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
