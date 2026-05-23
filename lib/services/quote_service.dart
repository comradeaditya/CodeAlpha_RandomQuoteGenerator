import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteService {
  static const String _baseUrl = 'https://zenquotes.io/api/random';

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return Quote.fromJson(data[0]);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return Quote(
        text: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
      );
    }
  }
}