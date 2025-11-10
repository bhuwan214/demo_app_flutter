import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🛍️ This is Products Page...',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}