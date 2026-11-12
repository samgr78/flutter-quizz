import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../models/question.dart';
import '../models/test_result.dart';
import '../services/question_service.dart';
import '../services/result_service.dart';
import 'login_page.dart';
import 'quiz_page.dart';

class HomePage extends StatefulWidget {
  final Candidate candidate;

  const HomePage({super.key, required this.candidate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _questionService = QuestionService();
  final _resultService = ResultService();

  Map<String, List<Question>> _questions = {};
  List<TestResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load the questions and the results of the candidate
  Future<void> _loadData() async {
    final questions = await _questionService.getQuestions();
    final results = await _resultService.getCandidateResults(widget.candidate);
    setState(() {
      _questions = questions;
      _results = results;
      _loading = false;
    });
  }

  // return the result of the category, or null if the test is not done yet
  TestResult? _getResult(String category) {
    for (final result in _results) {
      if (result.category == category) {
        return result;
      }
    }
    return null;
  }

  Future<void> _startTest(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          candidate: widget.candidate,
          category: category,
          questions: _questions[category]!,
        ),
      ),
    );
    // reload when we come back, to show the new score
    _loadData();
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
        title: const Text('Évaluations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Bienvenue ${widget.candidate.firstName} ${widget.candidate.lastName} !',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                // one card per category
                for (final category in _questions.keys) _buildTestCard(category),
              ],
            ),
    );
  }

  Widget _buildTestCard(String category) {
    final result = _getResult(category);
    final int count = _questions[category]!.length;

    return Card(
      child: ListTile(
        title: Text(category),
        subtitle: result == null
            ? Text('$count questions')
            : Text('Test terminé : ${result.score} / ${result.total}'),
        trailing: result == null
            ? ElevatedButton(
                onPressed: () => _startTest(category),
                child: const Text('Commencer'),
              )
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}
