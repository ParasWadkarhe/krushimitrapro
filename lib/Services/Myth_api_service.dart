import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Myth.dart';

class MythApiService {
  List<Myth> _myths = [];
  bool _isLoading = false;

  List<Myth> get myths => _myths;
  bool get isLoading => _isLoading;

  Future<List<Myth>> fetchMyths(String query) async {
    _isLoading = true;

    try {
      // Replace with a valid mythology API endpoint
      final url = 'https://newsapi.org/v2/everything?q=$query&apiKey=NEWS_API_KEY';
      final response = await http.get(Uri.parse(url));
      print(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _myths = (data['articles'] as List)
            .map((myth) => Myth.fromJson(myth))
            .toList();
        print(_myths);
      } else {
        _myths = [];
      }
    } catch (e) {
      _myths = [];
      debugPrint('Error fetching myths: $e');
    } finally {
      _isLoading = false;
    }

    return _myths;
  }
}
