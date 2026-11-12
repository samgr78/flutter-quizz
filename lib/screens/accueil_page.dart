import 'package:flutter/material.dart';

import '../models/candidat.dart';

/// Page affichée après l'inscription.
/// Elle accueillera plus tard la liste des évaluations disponibles.
class AccueilPage extends StatelessWidget {
  final Candidat candidat;

  const AccueilPage({super.key, required this.candidat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Évaluations')),
      body: Center(
        child: Text(
          'Bienvenue ${candidat.prenom} ${candidat.nom} !',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
