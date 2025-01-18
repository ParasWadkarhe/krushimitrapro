
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Models/Myth.dart';
import '../Services/myth_gemini_service.dart';

class MythList extends StatelessWidget {
  final List<Myth> myths;
  final MythGeminiService mythGeminiService;

  MythList({
    required this.myths,
    required this.mythGeminiService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myths.length,
      itemBuilder: (context, index) {
        final myth = myths[index];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              myth.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              myth.description ?? 'Description not available',
              style: TextStyle(color: Colors.green),
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.green,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Lottie.asset('assets/loading.json'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Generating interpretation...',
                            style: TextStyle(color: Color.fromRGBO(223, 240, 227, 1)),
                          ),
                        ],
                      ),
                    );
                  },
                );

                String interpretation = await mythGeminiService.interpretMyth(myth.title);

                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.green,
                      title: const Text(
                        'Gemini Interpretation',
                        style: TextStyle(color: Color.fromRGBO(223, 240, 227, 1)),
                      ),
                      content: Text(
                        interpretation,
                        style: const TextStyle(color: Color.fromRGBO(223, 240, 227, 1)),
                      ),
                      actions: [
                        TextButton(
                          style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(Colors.green)),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close',style: TextStyle(color: Color.fromRGBO(223, 240, 227, 1)),),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Interpret',style: TextStyle(color: Colors.green),),
            ),
          ),
        );
      },
    );
  }
}