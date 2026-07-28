import 'package:flutter/material.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

/// Lists every tracked counter with its views, clicks and click-through rate,
/// and lets the user reset all data.
class AnalyticsDashboardPage extends StatefulWidget {
  /// Creates the analytics dashboard page.
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  late Future<Map<String, CounterData>> _counters;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _counters = CounterAnalytics.getAllCounters();
  }

  Future<void> _clearAll() async {
    await CounterAnalytics.clear();
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(_reload),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, CounterData>>(
        future: _counters,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final counters =
              snapshot.data?.values.toList() ?? const <CounterData>[];
          if (counters.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: counters.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _CounterTile(data: counters[index]),
          );
        },
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({required this.data});

  final CounterData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
      title: Text(data.id),
      subtitle: Text('Views: ${data.views}   •   Clicks: ${data.clicks}'),
      trailing: Text(
        _formatCtr(data),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 12),
          const Text('No activity yet.\nScroll and tap products to see stats.',
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Formats the click-through rate (clicks / views), or `—` when there is
/// nothing to report yet.
String _formatCtr(CounterData data) {
  if (data.clicks == 0 || data.views == 0) return '—';
  final ratio = data.clicks / data.views * 100;
  return '${ratio.toStringAsFixed(0)}% CTR';
}
