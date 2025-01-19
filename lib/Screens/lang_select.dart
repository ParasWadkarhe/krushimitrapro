import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();

  // Method to get the selected language (static for easy access across files)
  static String getSelectedLanguage() => _LanguageSelectorState.selectedLanguage;
}

class _LanguageSelectorState extends State<LanguageSelector> {
  static String selectedLanguage = 'English'; // Default language

  final List<String> languages = ['English', 'Hindi', 'Marathi'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      items: languages.map((String language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Text(language),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedLanguage = newValue;
          });
        }
      },
      icon: const Icon(Icons.language),
      underline: Container(
        height: 2,
        color: Colors.green,
      ),
    );
  }
}
