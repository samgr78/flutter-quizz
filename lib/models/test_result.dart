class TestResult {
  final String lastName;
  final String firstName;

  final String email;
  final String category;
  final int score;
  final int total;
  final DateTime date;

  TestResult({
    required this.lastName,
    this.firstName = '',
    required this.email,
    required this.category,
    required this.score,
    required this.total,
    required this.date,
  });

   // Calcul automatique de l'année scolaire (Septembre N à Août N+1)
  String get schoolYear {
    final year = date.year;
    if (date.month >= 9) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  // Pourcentage de réussite
  double get percentage => total > 0 ? (score / total) * 100 : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'category': category,
      'score': score,
      'total': total,
      'date': date.toIso8601String(),
    };
  }

   factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      category: json['category'] ?? '',
      score: json['score'] ?? 0,
      total: json['total'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
