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
  void initState(){
    super.initState();
    fetchProdcts();
  }

  Future<void> fetchProdcts() async {
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
    return Expanded(
      child: Padding(
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
            final item =items[index];

            return ItemCard(
              imageUrl: item['image'] ?? 'https://via.placeholder.com/150',
              name: item['product_name'] ?? 'No Name',
              price: item['price'] ?? '0',
            );
          },
        ),
      ),
    );
  }
}


class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;

  const ItemCard({super.key, required this.imageUrl, required this.name, required this.price});

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
              child: Image.network(

                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
             Padding(
              padding:EdgeInsetsGeometry.all(10),
              child:Column(
                children:[
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rs $price',
                    style: TextStyle(fontSize: 14,
                     color: Colors.green,
                     fontWeight: FontWeight.w700
                     ),
                  ),
                  
                ]
              )),

        
          ],
        ),
      ),
    );
  }
}