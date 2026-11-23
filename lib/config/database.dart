import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppDatabase {
  static final String _uri = defaultTargetPlatform == TargetPlatform.android
      ? 'mongodb://10.0.2.2:27017/flutter_quizz'
      : 'mongodb://localhost:27017/flutter_quizz';

  static Db? _db;

  static const String candidates = 'candidates';
  static const String results = 'results';
  static const String questions = 'questions';
  static const String admins = 'admins';

  static Future<Db> getDb() async {
    _db ??= Db(_uri);
    if (!_db!.isConnected) {
      await _db!.open();
    }
    return _db!;
  }

  static Future<DbCollection> collection(String name) async {
    final db = await getDb();
    return db.collection(name);
  }

  static Future<void> init() async {
    final db = await getDb();
    await _createIndexes(db);
    await _addDefaultAdmins(db);
    await _addDefaultQuestions(db);
  }

  static const Map<String, Object> ignoreCase = {'locale': 'fr', 'strength': 2};

  static Future<void> _createIndexes(Db db) async {
    await db.runCommand({
      'createIndexes': candidates,
      'indexes': [
        {
          'key': {'lastName': 1, 'email': 1},
          'name': 'unique_lastName_email',
          'unique': true,
          'collation': ignoreCase,
        },
      ],
    });

    await db.runCommand({
      'createIndexes': results,
      'indexes': [
        {
          'key': {'lastName': 1, 'email': 1, 'category': 1},
          'name': 'unique_candidate_category',
          'unique': true,
          'collation': ignoreCase,
        },
      ],
    });
  }

  static Future<void> _addDefaultAdmins(Db db) async {
    final collection = db.collection(admins);
    if (await collection.count() > 0) return;

    final String data = await rootBundle.loadString('assets/admins.json');
    final List<dynamic> list = jsonDecode(data);
    await collection.insertMany(List<Map<String, dynamic>>.from(list));
  }

  static Future<void> _addDefaultQuestions(Db db) async {
    final collection = db.collection(questions);
    if (await collection.count() > 0) return;

    final String data = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> json = jsonDecode(data);

    // one document per quiz
    final List<Map<String, dynamic>> documents = [];
    json.forEach((category, list) {
      documents.add({'category': category, 'questions': list});
    });
    await collection.insertMany(documents);
  }
}