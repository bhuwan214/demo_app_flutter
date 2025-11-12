import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://ecommerce.atithyahms.com/api/ecommerce/products/all",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            items = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: .7,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return ItemCard(
            imageUrl: item['image'] ?? 'https://via.placeholder.com/150',
            name: item['product_name'] ?? 'No Name',
            price: item['price']?.toString() ?? '0',
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;

  const ItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 50);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Rs $price',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}