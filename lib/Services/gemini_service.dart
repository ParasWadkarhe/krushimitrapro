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
Please provide a comprehensive yet concise medical management plan for ${diseaseName.toUpperCase()} with the following specific details:

TREATMENT SCHEDULE:
- Provide a clear daily/weekly schedule for managing the condition
- Include medication timings if applicable
- List specific lifestyle modifications required
- Mention any dietary restrictions or recommendations

MONITORING PLAN:
- Key symptoms to track
- Vital signs to monitor
- Warning signs that require immediate medical attention

FOLLOW-UP CARE:
- Recommended frequency of check-ups
- Types of tests or examinations needed
- Specialists to consult if necessary$locationInfo
      $timeInfo

REGIONAL CONSIDERATIONS:
- Local healthcare resources available
- Season-specific precautions
- Environmental factors to consider

Format the response in clear sections with practical,simple text, actionable steps. Use simple language and avoid medical jargon where possible.
''';

      // Make the API request to generate content
      final response = await model.generateContent([Content.text(prompt)]);

      // Extract and parse the generated content
      final content = response.text ?? 'No content generated';

      final cleanContent = content.replaceAll('**', '');
      final cleanContent1 = cleanContent.replaceAll('*', '');
      final cleanContent2= cleanContent1.replaceAll('-', '');
      // Parse content into structured data (custom parsing logic based on response format)
      final Map<String, dynamic> result = _parseResponse(cleanContent2);

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

