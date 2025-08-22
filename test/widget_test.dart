import 'package:flutter_test/flutter_test.dart';
import 'package:paw_campus/main.dart'; // importa tu app

void main() {
  testWidgets('renderiza PawCampus', (tester) async {
    await tester.pumpWidget(const PawCampusApp());
    // Verificamos que aparezca el título en la pantalla
    expect(find.text('PawCampus'), findsOneWidget);
  });
}
