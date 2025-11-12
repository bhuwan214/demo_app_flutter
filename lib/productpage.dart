import 'package:flutter/material.dart';
import 'grid.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});


  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);

 return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: theme.colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: const ProductGrid(),
    );
  }
}