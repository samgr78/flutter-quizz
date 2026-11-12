import 'package:flutter/material.dart';

import '../models/candidat.dart';
import '../services/candidat_service.dart';
import 'accueil_page.dart';

/// Page contenant le formulaire d'inscription d'un candidat.
class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  // Clé qui permet de valider tous les champs du formulaire d'un coup.
  final _formKey = GlobalKey<FormState>();

  // Un contrôleur par champ texte pour récupérer ce que l'utilisateur tape.
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _adresseController = TextEditingController();

  String? _motivation;

  final _service = CandidatService();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  /// Vérifie qu'un champ obligatoire n'est pas vide.
  String? _validerObligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Vérifie que l'email est rempli et a un format correct (ex: nom@mail.fr).
  String? _validerEmail(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final regex = RegExp(r'^[\w.-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(valeur.trim())) {
      return 'Email incorrect';
    }
    return null;
  }

  /// Vérifie que l'âge est un nombre entre 15 et 99.
  String? _validerAge(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final age = int.tryParse(valeur.trim());
    if (age == null || age < 15 || age > 99) {
      return 'Âge incorrect (entre 15 et 99)';
    }
    return null;
  }

  /// Appelée quand on appuie sur le bouton "S'inscrire".
  Future<void> _inscrire() async {
    // Si un champ n'est pas valide, les messages d'erreur s'affichent
    // sous les champs concernés et on s'arrête là.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final candidat = Candidat(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      adresse: _adresseController.text.trim(),
      motivation: _motivation!,
    );

    final bool reussi = await _service.inscrire(candidat);

    // On vérifie que la page est toujours affichée après l'attente.
    if (!mounted) return;

    if (!reussi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un compte existe déjà avec ce nom et cet email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AccueilPage(candidat: candidat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: _validerObligatoire,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom *'),
                validator: _validerObligatoire,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: _validerEmail,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Âge *'),
                keyboardType: TextInputType.number,
                validator: _validerAge,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse postale *'),
                validator: _validerObligatoire,
              ),
              DropdownButtonFormField<String>(
                initialValue: _motivation,
                decoration: const InputDecoration(labelText: 'Motivation *'),
                items: motivations
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (valeur) {
                  setState(() {
                    _motivation = valeur;
                  });
                },
                validator: (valeur) =>
                    valeur == null ? 'Choisissez une motivation' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _inscrire,
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
