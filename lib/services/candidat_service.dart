import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidat.dart';

/// Gère l'enregistrement des candidats sur l'appareil.
///
/// Les candidats sont stockés sous forme d'une liste JSON
/// dans les SharedPreferences, sous la clé [_cle].
class CandidatService {
  static const String _cle = 'candidats';

  /// Retourne la liste de tous les candidats enregistrés.
  Future<List<Candidat>> getCandidats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? donnees = prefs.getString(_cle);
    if (donnees == null) {
      return [];
    }
    final List<dynamic> liste = jsonDecode(donnees);
    return liste.map((element) => Candidat.fromJson(element)).toList();
  }

  /// Vérifie si un candidat avec ce nom et cet email existe déjà.
  /// La comparaison ne tient pas compte des majuscules/minuscules.
  Future<bool> existeDeja(String nom, String email) async {
    final candidats = await getCandidats();
    for (final candidat in candidats) {
      if (candidat.nom.toLowerCase() == nom.toLowerCase() &&
          candidat.email.toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// Inscrit un nouveau candidat.
  ///
  /// Retourne `false` si un compte avec le même nom et email existe déjà,
  /// `true` si l'inscription a réussi.
  Future<bool> inscrire(Candidat candidat) async {
    if (await existeDeja(candidat.nom, candidat.email)) {
      return false;
    }
    final candidats = await getCandidats();
    candidats.add(candidat);

    final prefs = await SharedPreferences.getInstance();
    final String donnees = jsonEncode(candidats.map((c) => c.toJson()).toList());
    await prefs.setString(_cle, donnees);
    return true;
  }
}
