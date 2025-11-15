import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorite_photos';

  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) return {};
    
    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.cast<String>().toSet();
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(favorites.toList());
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  static Future<void> addFavorite(String photoPath) async {
    final favorites = await loadFavorites();
    favorites.add(photoPath);
    await saveFavorites(favorites);
  }

  static Future<void> removeFavorite(String photoPath) async {
    final favorites = await loadFavorites();
    favorites.remove(photoPath);
    await saveFavorites(favorites);
  }

  static Future<bool> isFavorite(String photoPath) async {
    final favorites = await loadFavorites();
    return favorites.contains(photoPath);
  }

  static Future<void> toggleFavorite(String photoPath) async {
    final favorites = await loadFavorites();
    if (favorites.contains(photoPath)) {
      favorites.remove(photoPath);
    } else {
      favorites.add(photoPath);
    }
    await saveFavorites(favorites);
  }
}
