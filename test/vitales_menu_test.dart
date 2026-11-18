import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/heart_rate_screen.dart';
import 'package:mi_app/screens/heart_rate_screen_jovenes.dart';
import 'package:mi_app/screens/medicamentos_list_meses_screen.dart';
import 'package:mi_app/screens/select_medicamento_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('es'),
  supportedLocales: const [Locale('en'), Locale('es')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

void main() {
  for (final c in [
    (
      'años',
      SelectMedicamentoScreen(
        paciente: Paciente(pesoKg: 22, edadAnios: 6, edadMeses: 0),
      ),
      HeartRateScreenJ,
    ),
    (
      'meses',
      MedicamentosListMesesScreen(
        paciente: Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 6),
      ),
      HeartRateScreen,
    ),
  ]) {
    testWidgets('${c.$1}: menú de signos vitales abre la tabla y vuelve', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(c.$2));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.monitor_heart_outlined).last);
      await tester.pumpAndSettle();
      expect(find.text('Signos vitales'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Abrir frecuencia cardíaca.
      await tester.tap(find.text('Latidos por minuto (lpm)'));
      await tester.pumpAndSettle();
      expect(find.byType(c.$3), findsOneWidget);

      // Al volver, el menú se reabre.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Signos vitales'), findsOneWidget);

      // PAM.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_outline).last);
      await tester.pumpAndSettle();
      expect(find.text('Mujeres'), findsOneWidget);
      expect(find.text('Hombres'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
