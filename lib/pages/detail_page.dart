
import 'package:flutter/material.dart';
import 'package:demo_app/pages/favorite_page.dart';
import 'package:demo_app/pages/cart_page.dart';

class DetailsPage extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String price;

  const DetailsPage({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isFavorite = false;
  bool isInCart = false;
  late final FavoriteItem favoriteItem;
  late final CartItem cartItem;
  VoidCallback? _listener;

  @override 
  void initState() {
    super.initState();

    favoriteItem = FavoriteItem(
      imageUrl: widget.imageUrl,
      name: widget.name,
      price: widget.price,
    );
    cartItem = CartItem(
      imageUrl: widget.imageUrl,
      name: widget.name,
      price: double.tryParse(widget.price) ?? 0.0,
    );

    isFavorite = favoritesNotifier.value.contains(favoriteItem);
    isInCart = cartNotifier.value.contains(cartItem);
    
    _listener = () {
      final currentFavorite = favoritesNotifier.value.contains(favoriteItem);
      final currentInCart = cartNotifier.value.contains(cartItem);
        
      if (mounted && 
         (currentFavorite != isFavorite || currentInCart != isInCart)) {
        setState(() {
          isFavorite = currentFavorite;
          isInCart = currentInCart;
        });
      }
    };
    favoritesNotifier.addListener(_listener!);
    cartNotifier.addListener(_listener!);
  }
          
  @override
  void dispose() {
    if (_listener != null) {
      favoritesNotifier.removeListener(_listener!);
      cartNotifier.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 400,
              width: double.infinity,
              color: isDark ? colorScheme.surfaceContainerHighest : Colors.grey[100],
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                    ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rs ${widget.price}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Description Section
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'loremipsum .',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Features
                  
                 
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    toggleCartItem(cartItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInCart 
                            ? '${widget.name} removed from cart'
                            : '${widget.name} added to cart'
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart),
                  label: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? Colors.red : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  toggleFavorite(favoriteItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites'
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite 
                    ? Colors.red 
                    : colorScheme.secondaryContainer,
                  foregroundColor: isFavorite
                    ? Colors.white
                    : colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



