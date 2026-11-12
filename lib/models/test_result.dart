class TestResult {
  // lastName + email identify the candidate (unique account)
  final String lastName;
  final String email;
  final String category;
  final int score;
  final int total;
  final DateTime date;

  TestResult({
    required this.lastName,
    required this.email,
    required this.category,
    required this.score,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastName': lastName,
      'email': email,
      'category': category,
      'score': score,
      'total': total,
      'date': date.toIso8601String(),
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      lastName: json['lastName'],
      email: json['email'],
      category: json['category'],
      score: json['score'],
      total: json['total'],
      date: DateTime.parse(json['date']),
    );
  }
}
