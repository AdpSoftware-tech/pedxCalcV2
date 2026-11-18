import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/main.dart';
import 'package:mi_app/screens/onboarding_screen.dart';

/// Prueba de humo: la app arranca y muestra la pantalla de bienvenida.
void main() {
  testWidgets('la app arranca en el onboarding', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Pedx Calc'), findsWidgets);
  });
}
