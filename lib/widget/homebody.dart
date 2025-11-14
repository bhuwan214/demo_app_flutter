import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../grid.dart';
import 'package:demo_app/widget/search_field.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
    final TextEditingController _searchController = TextEditingController();

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Header with profile
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.person, color: colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Alex',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          'Good Morning!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_bag_outlined, color: colorScheme.onSurface),
                      onPressed: () {},
                    ),
                  ],
                ),
                // const SizedBox(height: 10),

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

            

                // Category Chips
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       _CategoryChip(label: 'All', isSelected: true),
                //       _CategoryChip(label: 'Men', isSelected: false),
                //       _CategoryChip(label: 'Women', isSelected: false),
                //       _CategoryChip(label: 'Girls', isSelected: false),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 20),

                // Promotional Banner
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [colorScheme.primaryContainer, colorScheme.primary]
                          : [const Color(0xFFFF8A5B), const Color(0xFFFF6B3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 12, 25, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Your\nSpecial Sale\nUp to 40%',
                                style: TextStyle(
                                  color: isDark ? colorScheme.onPrimaryContainer : Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? colorScheme.surface : Colors.white,
                                  foregroundColor: isDark ? colorScheme.primary : const Color(0xFFFF6B3D),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                                ),
                                child: const Text('Shop Now' ,style: TextStyle(fontSize:12),),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: isDark
                              ? colorScheme.onPrimaryContainer.withOpacity(0.2)
                              : Colors.white.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const PopularProduct(),
              ],
            ),
          ),
        );
  }
}

// class _CategoryChip extends StatelessWidget {
//   final String label;
//   final bool isSelected;

//   const _CategoryChip({required this.label, required this.isSelected});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: FilterChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (bool value) {},
//         backgroundColor: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerHigh,
//         selectedColor: colorScheme.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//     );
//   }
// }

class PopularProduct extends StatefulWidget {
  const PopularProduct({super.key});

  @override
  State<PopularProduct> createState() => _PopularProductState();
}

class _PopularProductState extends State<PopularProduct> {
  bool showAll = false;
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopular();
  }

  Future<void> _fetchPopular() async {
    try {
      final resp = await http.get(
        Uri.parse('https://ecommerce.atithyahms.com/api/ecommerce/products/popular'),
      );
      if (resp.statusCode == 200 && mounted) {
        final data = json.decode(resp.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            items = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final displayItems = showAll ? items : (items.length > 4 ? items.sublist(0, 4) : items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (items.length > 4)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAll = !showAll; // Toggle to show all items or just 4
                  });
                },
                child: Text(
                  showAll ? 'Show Less' : 'See All',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (displayItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No popular products'),
            ),
          )
        else
       
          GridView.builder(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(), 
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .7,
            ),
            itemCount: displayItems.length, 
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return ItemCard(
                imageUrl: item['image']?.toString() ?? '',
                name: item['product_name']?.toString() ?? 'No Name',
                price: item['price']?.toString() ?? '0',
              );
            },
          ),
      ],
    );
  }
}