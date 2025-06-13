import '../Models/news_article.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON decoding

class NewsService {
  final String apiKey = NEWS_API_KEY;

  Future<List<NewsArticle>> fetchAgricultureNews(String country) async {
    final String url = country == 'global'
        ? 'https://newsapi.org/v2/everything?q=agriculture&apiKey=$apiKey'
        : 'https://newsapi.org/v2/top-headlines?country=$country&q=agriculture&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));
    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['articles'] is List) {
        List articles = data['articles'];
        return articles.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: articles not found');
      }
    } else {
      throw Exception('Failed to load agriculture news');
    }
  }
}
