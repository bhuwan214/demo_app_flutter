import 'package:flutter/material.dart';
import 'package:demo_app/pages/detail_page.dart';

/// Favorite model and in-memory store (moved here so there's a single file)
class FavoriteItem {
  final String imageUrl;
  final String name;
  final String price;
  int quantity;
  bool isSelected;

  FavoriteItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
  });

            
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItem &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(name, imageUrl);
}

final ValueNotifier<List<FavoriteItem>> favoritesNotifier =
    ValueNotifier<List<FavoriteItem>>([]);

bool isFavorite(FavoriteItem item) {
  return favoritesNotifier.value.contains(item);
}

void addFavorite(FavoriteItem item) {
  final list = List<FavoriteItem>.from(favoritesNotifier.value);
  if (!list.contains(item)) {
    list.add(item);
    favoritesNotifier.value = list;
  }
}

void removeFavorite(FavoriteItem item) {
  final list = List<FavoriteItem>.from(favoritesNotifier.value);
  if (list.remove(item)) {
    favoritesNotifier.value = list;
  }
}

void toggleFavorite(FavoriteItem item) {
  if (isFavorite(item)) {
    removeFavorite(item);
  } else {
    addFavorite(item);
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favourites')),
      body: ValueListenableBuilder<List<FavoriteItem>>(
        valueListenable: favoritesNotifier,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          'Rs ${item.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => removeFavorite(item),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>DetailsPage(
            imageUrl: item.imageUrl,
            name: item.name,
            price: item.price,
          ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}