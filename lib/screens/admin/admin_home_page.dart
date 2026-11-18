import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../services/question_service.dart';
import '../login_page.dart';
import 'admin_quiz_page.dart';
import 'admin_dashboard_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _service = QuestionService();
  final _quizNameController = TextEditingController();

  Map<String, List<Question>> _questions = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _quizNameController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _service.getQuestions();
    setState(() {
      _questions = questions;
      _loading = false;
    });
  }

  Future<void> _createQuiz() async {
    _quizNameController.clear();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau quiz'),
        content: TextField(
          controller: _quizNameController,
          decoration: const InputDecoration(labelText: 'Nom du quiz'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _quizNameController.text.trim()),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    if (_questions.containsKey(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un quiz avec ce nom existe déjà'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _questions[name] = [];
    });
    await _service.saveQuestions(_questions);
  }

  Future<void> _deleteQuiz(String category) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le quiz'),
        content: Text('Voulez-vous vraiment supprimer le quiz $category ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _questions.remove(category);
    });
    await _service.saveQuestions(_questions);
  }

  Future<void> _openQuiz(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminQuizPage(category: category),
      ),
    );
    _loadQuestions();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Tableau de bord',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createQuiz,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau quiz'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in _questions.keys)
            Card(
              child: ListTile(
                title: Text(category),
                subtitle: Text('${_questions[category]!.length} questions'),
                onTap: () => _openQuiz(category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Supprimer',
                  onPressed: () => _deleteQuiz(category),
                ),
              ),
            ),
        ],
      ),
    );
  }
}