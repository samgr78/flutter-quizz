import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

class QuestionService {
  static const String _storageKey = 'questions';

  // first time : question from json
  // 2nd time from the admin save
  Future<Map<String, List<Question>>> getQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_storageKey);
    data ??= await rootBundle.loadString('assets/questions.json');

    final Map<String, dynamic> json = jsonDecode(data);
    final Map<String, List<Question>> questions = {};
    json.forEach((category, list) {
      questions[category] =
          (list as List).map((item) => Question.fromJson(item)).toList();
    });
    return questions;
  }


  Future<void> saveQuestions(Map<String, List<Question>> questions) async {
    final Map<String, dynamic> json = {};
    questions.forEach((category, list) {
      json[category] = list.map((q) => q.toJson()).toList();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(json));
  }
}