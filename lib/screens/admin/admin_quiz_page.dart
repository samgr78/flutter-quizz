import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../services/question_service.dart';
import 'question_form_page.dart';

// list of the questions of one quiz, with add / edit / delete
class AdminQuizPage extends StatefulWidget {
  final String category;

  const AdminQuizPage({super.key, required this.category});

  @override
  State<AdminQuizPage> createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  final _service = QuestionService();

  Map<String, List<Question>> _allQuestions = {};
  bool _loading = true;

  // the questions of this quiz only
  List<Question> get _questions => _allQuestions[widget.category] ?? [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _service.getQuestions();
    setState(() {
      _allQuestions = questions;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _service.saveQuestions(_allQuestions);
  }

  Future<void> _addQuestion() async {
    final Question? question = await Navigator.push<Question>(
      context,
      MaterialPageRoute(builder: (context) => const QuestionFormPage()),
    );
    if (question == null) return;

    setState(() {
      _allQuestions[widget.category] = [..._questions, question];
    });
    await _save();
  }

  Future<void> _editQuestion(int index) async {
    final Question? question = await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormPage(question: _questions[index]),
      ),
    );
    if (question == null) return;

    setState(() {
      _questions[index] = question;
    });
    await _save();
  }

  Future<void> _deleteQuestion(int index) async {
    setState(() {
      _questions.removeAt(index);
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz ${widget.category}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une question'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(child: Text('Aucune question pour le moment'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Card(
            child: ListTile(
              title: Text(question.question),
              subtitle: Text(
                'Réponse : ${question.answers[question.correctAnswer]}'
                    ' • ${question.time} s',
              ),
              onTap: () => _editQuestion(index),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Supprimer',
                onPressed: () => _deleteQuestion(index),
              ),
            ),
          );
        },
      ),
    );
  }
}