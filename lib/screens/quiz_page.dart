import 'dart:async';

import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../models/question.dart';
import '../models/test_result.dart';
import '../services/result_service.dart';

class QuizPage extends StatefulWidget {
  final Candidate candidate;
  final String category;
  final List<Question> questions;

  const QuizPage({
    super.key,
    required this.candidate,
    required this.category,
    required this.questions,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _resultService = ResultService();

  int _currentIndex = 0;
  int _score = 0;
  // index of the answer chosen by the candidate, null if nothing chosen
  int? _selectedAnswer;
  bool _finished = false;

  Timer? _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Question get _currentQuestion => widget.questions[_currentIndex];

  // start the countdown for the current question
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _currentQuestion.time;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      // time is over: go to the next question
      if (_timeLeft <= 0) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    // avoid saving the result twice if the button is pressed again
    if (_finished) return;
    _timer?.cancel();

    if (_selectedAnswer == _currentQuestion.correctAnswer) {
      _score++;
    }

    // last question: the test is finished
    if (_currentIndex == widget.questions.length - 1) {
      _finished = true;
      _finishTest();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
    });
    _startTimer();
  }

  Future<void> _finishTest() async {
    final result = TestResult(
      lastName: widget.candidate.lastName,
      email: widget.candidate.email,
      category: widget.category,
      score: _score,
      total: widget.questions.length,
      date: DateTime.now(),
    );
    await _resultService.saveResult(result);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Test terminé'),
        content: Text('Votre score : $_score / ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    // back to the home page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final bool isLast = _currentIndex == widget.questions.length - 1;

    // PopScope blocks the back button: the test can't be left and restarted
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test ${widget.category}'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Question ${_currentIndex + 1} / ${widget.questions.length}'),
              const SizedBox(height: 8),
              // progress bar for the time left
              LinearProgressIndicator(value: _timeLeft / question.time),
              Text(
                'Temps restant : $_timeLeft s',
                textAlign: TextAlign.right,
                style: TextStyle(color: _timeLeft <= 5 ? Colors.red : null),
              ),
              const SizedBox(height: 16),
              Text(question.question, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              RadioGroup<int>(
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
                child: Column(
                  children: [
                    for (int i = 0; i < question.answers.length; i++)
                      RadioListTile<int>(
                        title: Text(question.answers[i]),
                        value: i,
                      ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(isLast ? 'Terminer' : 'Suivant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
