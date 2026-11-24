import '../config/database.dart';
import '../models/candidate.dart';
import '../models/test_result.dart';

class ResultService {
  // get all results of all candidates
  Future<List<TestResult>> getResults() async {
    final collection = await AppDatabase.collection(AppDatabase.results);
    final list = await collection.find().toList();
    return list.map((item) => TestResult.fromJson(item)).toList();
  }

  // get only the results of one candidate
  Future<List<TestResult>> getCandidateResults(Candidate candidate) async {
    final collection = await AppDatabase.collection(AppDatabase.results);
    final list = await collection.modernFind(
      filter: {'lastName': candidate.lastName, 'email': candidate.email},
      rawOptions: {'collation': AppDatabase.ignoreCase},
    ).toList();
    return list.map((item) => TestResult.fromJson(item)).toList();
  }

  // save a new result
  Future<void> saveResult(TestResult result) async {
    final collection = await AppDatabase.collection(AppDatabase.results);
    await collection.insertOne(result.toJson());
  }
}