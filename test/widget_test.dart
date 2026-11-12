import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_quizz/main.dart';
import 'package:flutter_quizz/models/candidat.dart';
import 'package:flutter_quizz/services/candidat_service.dart';

void main() {
  setUp(() {
    // Simule un stockage vide avant chaque test.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Affiche des erreurs si les champs sont vides',
      (WidgetTester tester) async {
    await tester.pumpWidget(const QuizzApp());

    await tester.tap(find.text("S'inscrire"));
    await tester.pump();

    expect(find.text('Ce champ est obligatoire'), findsNWidgets(5));
    expect(find.text('Choisissez une motivation'), findsOneWidget);
  });

  test('Refuse un deuxième compte avec le même nom et email', () async {
    final service = CandidatService();
    final candidat = Candidat(
      nom: 'Dupont',
      prenom: 'Marie',
      email: 'marie@mail.fr',
      age: 20,
      adresse: '1 rue de Paris',
      motivation: motivations.first,
    );

    expect(await service.inscrire(candidat), true);
    expect(await service.inscrire(candidat), false);
  });
}
