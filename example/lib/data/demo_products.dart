import 'package:flutter/material.dart';

/// A sample product shown in the demo feed.
@immutable
class Product {
  /// Creates a demo product.
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    this.tag,
  });

  /// Stable identifier used as the tracking key for views and clicks.
  final String id;

  /// Display name.
  final String name;

  /// Formatted price label.
  final String price;

  /// Leading icon standing in for a product image.
  final IconData icon;

  /// Optional marketing tag (e.g. "Sale", "New").
  final String? tag;
}

/// The products rendered in the demo feed.
const List<Product> demoProducts = <Product>[
  Product(
    id: 'product_headphones',
    name: 'Wireless Headphones',
    price: r'$89.99',
    icon: Icons.headphones,
    tag: 'Sale',
  ),
  Product(
    id: 'product_watch',
    name: 'Smart Watch',
    price: r'$199.00',
    icon: Icons.watch,
    tag: 'New',
  ),
  Product(
    id: 'product_speaker',
    name: 'Portable Speaker',
    price: r'$49.50',
    icon: Icons.speaker,
  ),
  Product(
    id: 'product_camera',
    name: 'Action Camera',
    price: r'$149.00',
    icon: Icons.photo_camera,
  ),
  Product(
    id: 'product_keyboard',
    name: 'Mechanical Keyboard',
    price: r'$79.00',
    icon: Icons.keyboard,
    tag: 'Popular',
  ),
];
