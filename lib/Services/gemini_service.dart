import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService extends ChangeNotifier {
  final String _model = 'gemini-1.5-flash'; // Define the Gemini model version
  static const String _apiKey = "AIzaSyC0rWE2B2NlhqrQRRTkQBZPRdQBKrnLgLg"; // Your API key

  Future<Map<String, dynamic>> fetchDiseaseDetails(String diseaseName, DateTime? timestamp, String? location) async {
    if (_apiKey.isEmpty) {
      return {'error': 'API Key is missing'};
    }

    try {
      // Create the GenerativeModel object
      final model = GenerativeModel(
        model: _model,
        apiKey: _apiKey,
      );

      // Construct the time and location information
      String locationInfo = '';
      if (location != null) {
        locationInfo = location;
      }

      String timeInfo = '';
      if (timestamp != null) {
        timeInfo = 'Timestamp: ${timestamp.toLocal().toString()}';
      }

      // Define the prompt for generating disease details
      final prompt = '''
      Provide short content for the following details for the disease: "$diseaseName":
      1. A schedule of activities to cure or manage the disease.
      2. The next recommended diagnosis date for follow-up.
      Include region and seasonal recommendations based on the given location and time.
      $locationInfo
      $timeInfo
      Use plain text, simple and easy-to-understand language, and avoid unnecessary symbols. 
      Keep the response in paragraph format.
      ''';

      // Make the API request to generate content
      final response = await model.generateContent([Content.text(prompt)]);

      // Extract and parse the generated content
      final content = response.text ?? 'No content generated';

      // Parse content into structured data (custom parsing logic based on response format)
      final Map<String, dynamic> result = _parseResponse(content);

      return result;
    } catch (e) {
      print('Error communicating with Gemini API: ${e.toString()}');
      return {'error': 'Error communicating with Gemini API'};
    }
  }

  /// Custom method to parse the response content
  Map<String, dynamic> _parseResponse(String content) {
    // Simple mock parser; customize based on actual Gemini API response format
    final lines = content.split('\n');
    final summary = lines.isNotEmpty ? lines[0] : 'No summary available';
    final schedule = lines.length > 1
        ? lines.sublist(1, lines.length - 1).map((e) => e.trim()).toList()
        : [];
    final nextAppointment = lines.isNotEmpty
        ? DateTime.now().add(Duration(days: 7)) // Mocking a follow-up date
        : DateTime.now();

    return {
      'summary': summary,
      'schedule': schedule,
      'nextAppointment': nextAppointment,
    };
  }
}

