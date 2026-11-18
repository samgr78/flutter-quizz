import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../models/test_result.dart';

//page displaying the candidate’s details and results
class ProfilePage extends StatelessWidget {
  final Candidate candidate;
  final List<TestResult> results;

  const ProfilePage({
    super.key,
    required this.candidate,
    required this.results,
  });

  Widget _info(String label, String value) {
    return ListTile(title: Text(label), subtitle: Text(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //candidate details
          _info('Nom', candidate.lastName),

          _info('Prénom', candidate.firstName),

          _info('Email', candidate.email),

          _info('Âge', '${candidate.age} ans'),

          _info('Adresse postale', candidate.address),

          _info('Motivation', candidate.motivation),

          //score section
          const SizedBox(height: 24),
          const Text('Mes résultats', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const Text('Aucun test réalisé pour le moment.')
          else
            for (final result in results)
              Card(
                child: ListTile(
                  title: Text(result.category),
                  trailing: Text(
                    '${result.score} / ${result.total}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}