import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate.dart';

class CandidateService {
  static const String _storageKey = 'candidates';

  // get all candidate
  Future<List<Candidate>> getCandidates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) {
      return [];
    }
    final List<dynamic> list = jsonDecode(data);
    return list.map((item) => Candidate.fromJson(item)).toList();
  }

  // valide if email already existe (lowercase or uppercase dont matter)
  Future<bool> alreadyExists(String lastName, String email) async {
    final candidates = await getCandidates();
    for (final candidate in candidates) {
      if (candidate.lastName.toLowerCase() == lastName.toLowerCase() &&
          candidate.email.toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  // create new candidate account
  Future<bool> register(Candidate candidate) async {
    if (await alreadyExists(candidate.lastName, candidate.email)) {
      return false;
    }
    final candidates = await getCandidates();
    candidates.add(candidate);

    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(candidates.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, data);
    return true;
  }
}
