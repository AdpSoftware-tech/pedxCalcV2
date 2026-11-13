import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/calculos_jovenes_detail_screen.dart';
import 'package:mi_app/screens/liquid_iv_detail_screen.dart';

Widget _app(Widget home, {String lang = 'en'}) => MaterialApp(
  locale: Locale(lang),
  supportedLocales: const [Locale('en'), Locale('es')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

/// Abre las pantallas de detalle que muestran sodio/HCO3 y comprueba que
/// los mensajes salen traducidos (y que no falla al construirse).
void main() {
  final paciente = Paciente(pesoKg: 20, edadAnios: 6, edadMeses: 0);

  CalculosJovenesDetailScreen jovenes(String nombre, String tipo, double v) =>
      CalculosJovenesDetailScreen(
        paciente: paciente,
        medicamento: Medicamento(id: '', nombre: nombre, categoria: ''),
        sodioValor: tipo == 'Sodio' ? v : 0,
        hco3Valor: tipo == 'HCO3' ? v : 0,
        liquidosIvValor: 100,
        calculoType: tipo,
      );

  testWidgets('jóvenes HCO3 ≥ 15 en inglés → "No deficit"', (tester) async {
    await tester.pumpWidget(_app(jovenes('Déficit de HCO3', 'HCO3', 18)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('No deficit'), findsWidgets);
  });

  testWidgets('jóvenes sodio 120 → valor sin prefijo "Déficit:"', (
    tester,
  ) async {
    await tester.pumpWidget(_app(jovenes('Déficit de Sodio', 'Sodio', 120)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Déficit:'), findsNothing);
    expect(find.textContaining('30'), findsWidgets);
  });

  testWidgets('jóvenes sodio en español → "Sin déficit"', (tester) async {
    await tester.pumpWidget(
      _app(jovenes('Déficit de Sodio', 'Sodio', 135), lang: 'es'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin déficit'), findsWidgets);
  });

  testWidgets('meses (detalle) sodio vacío en inglés → pide el dato', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LiquidIVDetailScreen(
          paciente: Paciente(pesoKg: 7, edadAnios: 0, edadMeses: 6),
          medicamento: Medicamento(
            id: '',
            nombre: 'Déficit de Sodio',
            categoria: 'Reposición de Sodio',
          ),
          porcentajeLiquidos: 100,
          sodioValor: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining("Enter the patient's sodium"), findsWidgets);
  });
}
