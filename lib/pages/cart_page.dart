import 'package:flutter/material.dart';
import 'package:demo_app/pages/detail_page.dart';
import 'package:demo_app/pages/checkout_page.dart';

class CartItem {
  final String name;
  final String imageUrl;
  final double price;
  // final String description;
  int quantity;
  bool isSelected;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    // this.description = '',
    this.quantity = 1,
    this.isSelected = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(name, imageUrl);
}

final ValueNotifier<List<CartItem>> cartNotifier =
    ValueNotifier<List<CartItem>>([]);

bool isInCart(CartItem item) {
  return cartNotifier.value.contains(item);
}

void addCartItem(CartItem item) {
  final list = List<CartItem>.from(cartNotifier.value);
  if (!list.contains(item)) {
    list.add(item);
    cartNotifier.value = list;
  }
}

void removeCartItem(CartItem item) {
  final list = List<CartItem>.from(cartNotifier.value);
  if (list.remove(item)) {
    cartNotifier.value = list;
  }
}

void toggleCartItem(CartItem item) {
  if (isInCart(item)) {
    removeCartItem(item);
  } else {
    addCartItem(item);
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double calculateTotal(List<CartItem> items) {
    double total = 0;
    for (var item in items) {
      if (item.isSelected) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart',
      style: TextStyle(fontWeight: FontWeight.bold)
      ,), centerTitle: true,  ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartNotifier,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No items added to cart yet'));
          }

          return Column(
            children: [
              const Padding(padding: EdgeInsets.all(16.0)),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: IntrinsicWidth(
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 0.8,
                                child: Checkbox(
                                  value: item.isSelected,
                                  onChanged: (value) {
                                    item.isSelected = value!;
                                    cartNotifier.value = List<CartItem>.from(
                                      cartNotifier.value,
                                    );
                                  },
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.imageUrl.startsWith('http')
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 47,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                    : Image.asset(
                                        item.imageUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IntrinsicWidth(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Rs ${item.price}',
                                      style: const TextStyle(
                                      
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints.tightFor(
                                        width: 20,
                                        height: 20,
                                    
                                      ),
                                      iconSize: 16,
                                      splashRadius: 30,
                                      
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                          cartNotifier.value = List<CartItem>.from(
                                            cartNotifier.value,
                                          );
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints.tightFor(
                                        width: 15,
                                        height: 20,
                                      ),
                                      iconSize: 16,
                                      splashRadius: 16,
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        item.quantity++;
                                        cartNotifier.value = List<CartItem>.from(
                                          cartNotifier.value,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => removeCartItem(item),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>DetailsPage(
              imageUrl: item.imageUrl,
              name: item.name,
              price: item.price.toString(),
            ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<List<CartItem>>(
                      valueListenable: cartNotifier,
                      builder: (context, list, _) {
                        double total = calculateTotal(list);
                        return Text(
                          'Total: Rs $total',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Get selected items
                        final selectedItems = list
                            .where((item) => item.isSelected)
                            .toList();

                        if (selectedItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select items to checkout'),
                            ),
                          );
                          return;
                        }

                        // Navigate to checkout page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              cartItems: selectedItems,
                              totalAmount: calculateTotal(selectedItems),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}