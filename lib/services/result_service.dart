import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate.dart';
import '../models/test_result.dart';

class ResultService {
  static const String _storageKey = 'results';

  // get all results of all candidates
  Future<List<TestResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) {
      return [];
    }
    final List<dynamic> list = jsonDecode(data);
    return list.map((item) => TestResult.fromJson(item)).toList();
  }

  // get only the results of one candidate
  Future<List<TestResult>> getCandidateResults(Candidate candidate) async {
    final results = await getResults();
    return results
        .where((r) =>
            r.lastName.toLowerCase() == candidate.lastName.toLowerCase() &&
            r.email.toLowerCase() == candidate.email.toLowerCase())
        .toList();
  }

  // save a new result
  Future<void> saveResult(TestResult result) async {
    final results = await getResults();
    results.add(result);

    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(results.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }
}
