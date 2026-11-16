import 'package:flutter/material.dart';

import '../models/candidate.dart';

class ProfilePage extends StatelessWidget {
  final Candidate candidate;

  const ProfilePage({super.key, required this.candidate});

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
          _info('Nom', candidate.lastName),
          _info('Prénom', candidate.firstName),
          _info('Email', candidate.email),
          _info('Âge', '${candidate.age} ans'),
          _info('Adresse postale', candidate.address),
          _info('Motivation', candidate.motivation),
        ],
      ),
    );
  }
}