import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/admin.dart';

class AdminService {
  // the admin account is create with json file
  Future<List<Admin>> getAdmins() async {
    final String data = await rootBundle.loadString('assets/admins.json');
    final List<dynamic> list = jsonDecode(data);
    return list.map((item) => Admin.fromJson(item)).toList();
  }

  // return the admin if email and password are good, null otherwise
  Future<Admin?> login(String email, String password) async {
    final admins = await getAdmins();
    for (final admin in admins) {
      if (admin.email.toLowerCase() == email.toLowerCase() &&
          admin.password == password) {
        return admin;
      }
    }
    return null;
  }
}