import 'package:flutter/material.dart';

import '../data/demo_products.dart';
import '../widgets/product_card.dart';
import 'analytics_dashboard_page.dart';

/// The main feed of products. Scrolling a card into view records a view;
/// tapping a card records a click.
class ProductFeedPage extends StatelessWidget {
  /// Creates the product feed page.
  const ProductFeedPage({super.key});

  void _openDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AnalyticsDashboardPage()),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text('Opened ${product.name}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
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
        itemCount: demoProducts.length,
        itemBuilder: (context, index) {
          final product = demoProducts[index];
          return ProductCard(
            product: product,
            onTap: () => _openProduct(context, product),
          );
        },
      ),
    );
  }
}
