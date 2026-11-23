import 'package:flutter/material.dart';

import 'config/database.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  // it reads the json files of assets
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppDatabase.init();
  } catch (e) {
    debugPrint('Cannot connect to MongoDB, is it started? $e');
  }

  runApp(const QuizzApp());
}

class QuizzApp extends StatelessWidget {
  const QuizzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quizz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const LoginPage(),
    );
  }
}
