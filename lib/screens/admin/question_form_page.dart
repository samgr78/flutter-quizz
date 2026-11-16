import 'package:flutter/material.dart';

import '../../models/question.dart';

// form to create a question, or edit it if already question
// the page return the question with Navigator.pop
class QuestionFormPage extends StatefulWidget {
  final Question? question;

  const QuestionFormPage({super.key, this.question});

  @override
  State<QuestionFormPage> createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends State<QuestionFormPage> {
  static const int answerCount = 4;

  final _formKey = GlobalKey<FormState>();

  final _questionController = TextEditingController();
  final _timeController = TextEditingController(text: '20');
  // one controller per answer
  final List<TextEditingController> _answerControllers =
  List.generate(answerCount, (index) => TextEditingController());

  int _correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    if (question != null) {
      _questionController.text = question.question;
      _timeController.text = question.time.toString();
      _correctAnswer = question.correctAnswer;
      for (int i = 0; i < question.answers.length && i < answerCount; i++) {
        _answerControllers[i].text = question.answers[i];
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _timeController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _validateTime(String? value) {
    final time = int.tryParse(value?.trim() ?? '');
    if (time == null || time < 5 || time > 300) {
      return 'Temps incorrect (entre 5 et 300 secondes)';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final question = Question(
      question: _questionController.text.trim(),
      answers: _answerControllers.map((c) => c.text.trim()).toList(),
      correctAnswer: _correctAnswer,
      time: int.parse(_timeController.text.trim()),
    );

    // send the question back to the previous page
    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.question != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la question' : 'Nouvelle question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                maxLines: null,
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Temps limite (secondes)',
                ),
                keyboardType: TextInputType.number,
                validator: _validateTime,
              ),
              const SizedBox(height: 16),
              const Text('Réponses (cochez la bonne réponse) :'),
              RadioGroup<int>(
                groupValue: _correctAnswer,
                onChanged: (value) {
                  setState(() {
                    _correctAnswer = value!;
                  });
                },
                child: Column(
                  children: [
                    for (int i = 0; i < answerCount; i++)
                      Row(
                        children: [
                          Radio<int>(value: i),
                          Expanded(
                            child: TextFormField(
                              controller: _answerControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Réponse ${i + 1}',
                              ),
                              validator: _validateRequired,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}