import 'package:flutter/material.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable logs and use the default SharedPreferences storage.
  CounterTrackerService.instance.configure(enableLogs: true);
  await CounterTrackerService.instance.init();

  runApp(const ExampleApp());
}

/// Root widget of the example application.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nn_counter_tracker demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// The demo feed: a mix of products, promotions, coupons and banners.
const List<_Item> _demoItems = <_Item>[
  _Item('product_001', 'Wireless Headphones', r'$89.99', Icons.headphones),
  _Item(
      'promo_001', 'Summer Sale — 50% Off', 'Limited time', Icons.local_offer),
  _Item('coupon_001', 'SAVE20 Coupon', '20% off any order',
      Icons.confirmation_number),
  _Item('product_002', 'Smart Watch', r'$199.00', Icons.watch),
  _Item('banner_001', 'New Arrivals Banner', 'Explore now', Icons.campaign),
];

/// Home page with a tracked feed and an analytics dashboard.
class HomePage extends StatelessWidget {
  /// Creates the home page.
  const HomePage({super.key});

  void _openDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Tracker Demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analytics dashboard',
            onPressed: () => _openDashboard(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _demoItems.length,
        itemBuilder: (context, index) {
          final item = _demoItems[index];
          return CounterTracker(
            id: item.id,
            trackView: true,
            trackClick: true,
            visibilityThreshold: 0.5,
            cooldownDuration: const Duration(seconds: 3),
            onViewed: (count) => debugPrint('viewed ${item.id}: $count'),
            onClicked: (count) => debugPrint('clicked ${item.id}: $count'),
            child: _TrackedCard(item: item),
          );
        },
      ),
    );
  }
}

class _TrackedCard extends StatelessWidget {
  const _TrackedCard({required this.item});

  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              child: Icon(item.icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  CounterBuilder(
                    id: item.id,
                    builder: (context, data, _) => Row(
                      children: <Widget>[
                        _Stat(icon: Icons.visibility, value: data.views),
                        const SizedBox(width: 16),
                        _Stat(icon: Icons.touch_app, value: data.clicks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text('$value'),
      ],
    );
  }
}

/// Displays every tracked counter and lets the user reset them.
class DashboardPage extends StatefulWidget {
  /// Creates the dashboard page.
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, CounterData>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = CounterAnalytics.getAllCounters();
  }

  Future<void> _clear() async {
    await CounterAnalytics.clear();
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_reload),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all',
            onPressed: _clear,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, CounterData>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final counters = snapshot.data!.values.toList();
          if (counters.isEmpty) {
            return const Center(child: Text('No data yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: counters.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = counters[index];
              return ListTile(
                title: Text(c.id),
                subtitle: Text('Views: ${c.views}   •   Clicks: ${c.clicks}'),
                trailing: Text(_formatCtr(c)),
              );
            },
          );
        },
      ),
    );
  }
}

/// Formats the click-through rate (clicks / views) for a counter, or `—` when
/// there is nothing to report yet.
String _formatCtr(CounterData data) {
  if (data.clicks == 0 || data.views == 0) return '—';
  final ratio = data.clicks / data.views * 100;
  return '${ratio.toStringAsFixed(0)}% CTR';
}

class _Item {
  const _Item(this.id, this.title, this.subtitle, this.icon);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
