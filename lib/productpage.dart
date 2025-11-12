import 'package:flutter/material.dart';
import 'package:demo_app/grid.dart';
import 'package:demo_app/widget/search_field.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: theme.colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Reusable Search Widget
          SearchTextField(
            controller: _searchController,
            hintText: 'Search products...',
            onChanged: (value) {
              
              setState(() {});
            },
            onClear: () {
              setState(() {});
            },
          ),
          // Product Grid
          Expanded(
            child: ProductGrid(
              apiUrl: "https://ecommerce.atithyahms.com/api/ecommerce/products/all",
              searchController: _searchController,
            ),
          ),
        ],
      ),
    );
  }
}