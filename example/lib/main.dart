import 'package:flutter/material.dart';
import 'package:nn_counter_tracker/nn_counter_tracker.dart';

import 'pages/product_feed_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable logs. Uses the default plugin-free in-memory storage, so this demo
  // runs on every platform (including Windows) with no extra setup.
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ProductFeedPage(),
    );
  }
}
