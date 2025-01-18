import 'package:flutter/material.dart';
import '../Services/Myth_api_service.dart';
import 'Myth_Result_Screen.dart';

class MythPage extends StatefulWidget {
  @override
  _MythPageState createState() => _MythPageState();
}

class _MythPageState extends State<MythPage> {
  final _searchController = TextEditingController();
  final _mythApiService = MythApiService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.purple),
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter search query',
                labelStyle: TextStyle(color: Colors.purple),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String query = _searchController.text.trim();
                print(query);
                if (query.isNotEmpty) {
                  await _mythApiService.fetchMyths(query);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => MythResultScreen(mythApiService: _mythApiService),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                }
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}