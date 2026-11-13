import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/calculos_especiales_jovenes_screen.dart';
import 'package:mi_app/screens/calculos_especiales_screen.dart';
import 'package:mi_app/widgets/calc_especial_widgets.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('en'),
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
  for (final caso in [
    (
      'meses',
      CalculosEspecialesScreen(
        paciente: Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 6),
      ),
    ),
    (
      'años',
      CalculosEspecialesJovenesScreen(
        paciente: Paciente(pesoKg: 22, edadAnios: 6, edadMeses: 0),
      ),
    ),
  ]) {
    testWidgets('${caso.$1}: sin sodio/HCO3 no se muestran déficits', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(caso.$2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Campos vacíos al abrir.
      for (final k in ['input-sodio', 'input-hco3']) {
        final campo = tester.widget<TextField>(find.byKey(ValueKey(k)));
        expect(campo.controller!.text, isEmpty, reason: k);
      }
      expect(find.text("Enter the patient's sodium"), findsOneWidget);
      expect(find.text("Enter the patient's HCO3"), findsOneWidget);

      // Al ingresar sodio aparece el déficit numérico.
      await tester.enterText(find.byKey(const ValueKey('input-sodio')), '120');
      await tester.pumpAndSettle();
      expect(find.text("Enter the patient's sodium"), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  test('formato de resultados: unidades y decimales uniformes', () {
    expect(CalcResultRow.formatear('320.0 ml'), (valor: '320', unidad: 'mL'));
    expect(CalcResultRow.formatear('1540.00 cc'), (
      valor: '1540',
      unidad: 'mL',
    ));
    expect(CalcResultRow.formatear('33.33 ml/h'), (
      valor: '33.3',
      unidad: 'mL/h',
    ));
    expect(CalcResultRow.formatear('13.0 ml/h'), (valor: '13', unidad: 'mL/h'));
    expect(CalcResultRow.formatear('Enter the patient\'s sodium'), isNull);
  });
}
