import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/main.dart';
import 'package:mi_app/screens/instrucciones_screen_with_terms.dart';

void main() {
  testWidgets('botón ES/EN cambia el idioma y no hay overflow en 320 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    AppLocaleController.set(const Locale('es'));
    addTearDown(() => AppLocaleController.set(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const InstruccionesScreenWithTerms(),
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
    expect(find.text('Resumen rápido'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('lang-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('Seguridad'), findsNothing);

    // Diálogo de seguridad traducido.
    await tester.tap(find.byKey(const ValueKey('btn-security')));
    await tester.pumpAndSettle();
    expect(find.text('Information about the app\'s security.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
