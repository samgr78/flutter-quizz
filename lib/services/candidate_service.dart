import '../config/database.dart';
import '../models/candidate.dart';

class CandidateService {
  // get all candidate
  Future<List<Candidate>> getCandidates() async {
    final collection = await AppDatabase.collection(AppDatabase.candidates);
    final list = await collection.find().toList();
    return list.map((item) => Candidate.fromJson(item)).toList();
  }

  // find the candidate with this last name and email
  Future<Candidate?> login(String lastName, String email) async {
    final collection = await AppDatabase.collection(AppDatabase.candidates);
    final list = await collection.modernFind(
      filter: {'lastName': lastName, 'email': email},
      rawOptions: {'collation': AppDatabase.ignoreCase},
    ).toList();

    if (list.isEmpty) return null;
    return Candidate.fromJson(list.first);
  }

  Future<bool> alreadyExists(String lastName, String email) async {
    return await login(lastName, email) != null;
  }

  // false if the account already exists
  Future<bool> register(Candidate candidate) async {
    final collection = await AppDatabase.collection(AppDatabase.candidates);
    final result = await collection.insertOne(candidate.toJson());
    return result.isSuccess;
  }
}