import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_quizz/main.dart';
import 'package:flutter_quizz/models/candidate.dart';
import 'package:flutter_quizz/services/candidate_service.dart';

void main() {
  setUp(() {
    // Fake an empty storage before each test.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows errors when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizzApp());

    await tester.tap(find.text("S'inscrire"));
    await tester.pump();

    expect(find.text('Ce champ est obligatoire'), findsNWidgets(5));
    expect(find.text('Choisissez une motivation'), findsOneWidget);
  });

  test('Refuses a second account with the same last name and email', () async {
    final service = CandidateService();
    final candidate = Candidate(
      lastName: 'Dupont',
      firstName: 'Marie',
      email: 'marie@mail.fr',
      age: 20,
      address: '1 rue de Paris',
      motivation: motivations.first,
    );

    expect(await service.register(candidate), true);
    expect(await service.register(candidate), false);
  });
}
