import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../Screens/Welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure the app is initialized
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
