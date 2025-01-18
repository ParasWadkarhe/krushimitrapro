import 'package:flutter/material.dart';
import '../Services/Myth_api_service.dart';
import '../Models/Myth.dart';
import '../Services/myth_gemini_service.dart';
import '../Widgets/myth_list.dart';

class MythResultScreen extends StatelessWidget {
  final MythApiService mythApiService;

  const MythResultScreen({Key? key, required this.mythApiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Myth Search Results'),
      ),
      body: mythApiService.isLoading
          ? Center(child: CircularProgressIndicator())
          : mythApiService.myths.isNotEmpty
          ? MythList(
        myths: mythApiService.myths,
        mythGeminiService: MythGeminiService(),
      )
          : Center(child: Text('No myths found for the query')),
    );
  }
}