import '../config/database.dart';
import '../models/question.dart';

class QuestionService {
  // returns { 'Java': [questions], 'Algo': [questions]}
  Future<Map<String, List<Question>>> getQuestions() async {
    final collection = await AppDatabase.collection(AppDatabase.questions);
    final list = await collection.find().toList();

    final Map<String, List<Question>> questions = {};
    for (final quiz in list) {
      questions[quiz['category']] = (quiz['questions'] as List)
          .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return questions;
  }

  // delete all quizz and save them again
  Future<void> saveQuestions(Map<String, List<Question>> questions) async {
    final collection = await AppDatabase.collection(AppDatabase.questions);
    await collection.deleteMany({});

    final List<Map<String, dynamic>> documents = [];
    questions.forEach((category, list) {
      documents.add({
        'category': category,
        'questions': list.map((q) => q.toJson()).toList(),
      });
    });

    if (documents.isNotEmpty) {
      await collection.insertMany(documents);
    }
  }
}