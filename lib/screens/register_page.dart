import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/candidate_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // key to validate all form
  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  String? _motivation;

  final _service = CandidateService();

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // if field is empty
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }


  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final regex = RegExp(r'^[\w.-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Email incorrect';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 1 || age > 99) {
      return 'Âge incorrect';
    }
    return null;
  }

  Future<void> _register() async {
    // If a field is not valid, the error messages are shown
    // under the fields and we stop here.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final candidate = Candidate(
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      address: _addressController.text.trim(),
      motivation: _motivation!,
    );

    final bool success = await _service.register(candidate);


    if (!mounted) return;

    if (!success) {
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
      MaterialPageRoute(builder: (context) => HomePage(candidate: candidate)),
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
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom *'),
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Âge *'),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse postale *'),
                validator: _validateRequired,
              ),
              DropdownButtonFormField<String>(
                initialValue: _motivation,
                decoration: const InputDecoration(labelText: 'Motivation *'),
                items: motivations
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _motivation = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Choisissez une motivation' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
