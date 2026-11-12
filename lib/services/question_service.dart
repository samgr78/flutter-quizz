import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';

class QuestionService {
  // read the json file and return the questions of each category
  // ex: {"Java": [...], "Algo": [...], "HTML/CSS": [...]}
  Future<Map<String, List<Question>>> getQuestions() async {
    final String data = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> json = jsonDecode(data);

    final Map<String, List<Question>> questions = {};
    json.forEach((category, list) {
      questions[category] =
          (list as List).map((item) => Question.fromJson(item)).toList();
    });
    return questions;
  }
}
