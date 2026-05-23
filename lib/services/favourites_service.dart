import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class FavouritesService {
  static const String _key = 'favourite_quotes';

  Future<List<Quote>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    return saved.map((item) {
      final map = jsonDecode(item);
      return Quote(text: map['text'], author: map['author']);
    }).toList();
  }

  Future<void> addFavourite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    final String encoded =
        jsonEncode({'text': quote.text, 'author': quote.author});
    if (!saved.contains(encoded)) {
      saved.add(encoded);
      await prefs.setStringList(_key, saved);
    }
  }

  Future<void> removeFavourite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    final String encoded =
        jsonEncode({'text': quote.text, 'author': quote.author});
    saved.remove(encoded);
    await prefs.setStringList(_key, saved);
  }

  Future<bool> isFavourite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    final String encoded =
        jsonEncode({'text': quote.text, 'author': quote.author});
    return saved.contains(encoded);
  }
}