import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MythGeminiService {
  final String _model = 'gemini-1.5-flash'; // Define the model version

  Future<String> interpretMyth(String mythTitle) async {
    // API Key for Google Generative AI
    
    const apiKey = GEMINI_API_KEY;

    if (apiKey.isEmpty) {
      return 'API Key is missing';
    }

    try {
      // Create the GenerativeModel object
      final model = GenerativeModel(
        model: _model,
        apiKey: apiKey,
      );

      // Define the prompt for generating content
      final prompt = 'Provide an insightful interpretation of this mythology story in 80 words or fewer: $mythTitle';

      // Generate content via API
      final response = await model.generateContent([Content.text(prompt)]);

      // Return the generated text or handle null cases
      return response.text ?? 'No interpretation generated';
    } catch (e) {
      debugPrint('Error communicating with Gemini API: ${e.toString()}');
      return 'Error communicating with Gemini API';
    }
  }
}
