/// Les motivations possibles d'un candidat (liste déroulante du formulaire).
const List<String> motivations = [
  "Poursuite d'études",
  'Reconversion pro',
  'Réorientation',
];

/// Représente un candidat inscrit sur la plateforme.
class Candidat {
  final String nom;
  final String prenom;
  final String email;
  final int age;
  final String adresse;
  final String motivation;

  Candidat({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.age,
    required this.adresse,
    required this.motivation,
  });

  /// Transforme le candidat en Map pour pouvoir l'enregistrer en JSON.
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'age': age,
      'adresse': adresse,
      'motivation': motivation,
    };
  }

  /// Recrée un candidat à partir d'une Map lue depuis le JSON.
  factory Candidat.fromJson(Map<String, dynamic> json) {
    return Candidat(
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      age: json['age'],
      adresse: json['adresse'],
      motivation: json['motivation'],
    );
  }
}
