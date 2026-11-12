class Question {
  final String question;
  final List<String> answers;
  // index of the good answer in the answers list
  final int correctAnswer;
  // time limit in seconds
  final int time;

  Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.time,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'],
      time: json['time'],
    );
  }
}
