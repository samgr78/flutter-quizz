import '../config/database.dart';
import '../models/admin.dart';

class AdminService {
  // admins are added in the database at the first start
  Future<List<Admin>> getAdmins() async {
    final collection = await AppDatabase.collection(AppDatabase.admins);
    final list = await collection.find().toList();
    return list.map((item) => Admin.fromJson(item)).toList();
  }

  // return the admin if email and password are good
  Future<Admin?> login(String email, String password) async {
    final collection = await AppDatabase.collection(AppDatabase.admins);
    final list = await collection.modernFind(
      filter: {'email': email, 'password': password},
      rawOptions: {'collation': AppDatabase.ignoreCase},
    ).toList();

    if (list.isEmpty) return null;
    return Admin.fromJson(list.first);
  }
}