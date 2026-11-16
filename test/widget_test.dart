import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_quizz/models/candidate.dart';
import 'package:flutter_quizz/models/question.dart';
import 'package:flutter_quizz/screens/quiz_page.dart';
import 'package:flutter_quizz/screens/register_page.dart';
import 'package:flutter_quizz/services/candidate_service.dart';
import 'package:flutter_quizz/services/result_service.dart';

final candidate = Candidate(
  lastName: 'Dupont',
  firstName: 'Marie',
  email: 'marie@mail.fr',
  age: 20,
  address: '1 rue de Paris',
  motivation: motivations.first,
);

final questions = [
  Question(question: 'Q1', answers: ['A', 'B'], correctAnswer: 0, time: 10),
  Question(question: 'Q2', answers: ['A', 'B'], correctAnswer: 1, time: 10),
];

void main() {
  setUp(() {
    // Fake an empty storage before each test.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows errors when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.tap(find.text("S'inscrire"));
    await tester.pump();

    expect(find.text('Ce champ est obligatoire'), findsNWidgets(5));
    expect(find.text('Choisissez une motivation'), findsOneWidget);
  });

  test('Refuses a second account with the same last name and email', () async {
    final service = CandidateService();

    expect(await service.register(candidate), true);
    expect(await service.register(candidate), false);
  });

  test('Login finds a registered candidate', () async {
    final service = CandidateService();
    await service.register(candidate);

    expect(await service.login('dupont', 'MARIE@mail.fr'), isNotNull);
    expect(await service.login('Martin', 'marie@mail.fr'), isNull);
  });

  testWidgets('Quiz counts the score and saves the result',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: QuizPage(candidate: candidate, category: 'Java', questions: questions),
    ));

    // good answer to Q1
    await tester.tap(find.text('A'));
    await tester.tap(find.text('Suivant'));
    await tester.pump();

    // no answer to Q2, wait for the timer to end
    expect(find.text('Q2'), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();

    expect(find.text('Votre score : 1 / 2'), findsOneWidget);

    final results = await tester.runAsync(
      () => ResultService().getCandidateResults(candidate),
    );
    expect(results!.length, 1);
    expect(results.first.category, 'Java');
    expect(results.first.score, 1);
  });
}
