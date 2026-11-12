import 'package:flutter/material.dart';

import '../models/candidate.dart';


class HomePage extends StatelessWidget {
  final Candidate candidate;

  const HomePage({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Évaluations')),
      body: Center(
        child: Text(
          'Bienvenue ${candidate.firstName} ${candidate.lastName} !',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
