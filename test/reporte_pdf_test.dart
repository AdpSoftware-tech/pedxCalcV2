import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/data/menu_categorias.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/medicamentos_list_meses_screen.dart';
import 'package:mi_app/screens/select_medicamento_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// El reporte se genera con las letras incluidas en la app.
/// En los tests el internet está bloqueado: si dependiera de Google Fonts,
/// fallaría aquí.
void main() {
  for (final c in [
    (
      'años, peso estimado',
      SelectMedicamentoScreen(
        paciente: Paciente(pesoKg: 22, edadAnios: 6, edadMeses: 0),
        esPesoEstimado: true,
      ),
    ),
    (
      'meses, sin edad',
      MedicamentosListMesesScreen(
        paciente: Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 0),
      ),
    ),
  ]) {
    testWidgets('reporte PDF sin internet: ${c.$1}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: c.$2,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.print));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final preview = tester.widget<PdfPreview>(find.byType(PdfPreview));
      final bytes = await tester.runAsync(
        () async => await preview.build(PdfPageFormat.letter),
      );
      expect(bytes, isNotNull);
      expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(10000));
      await tester.pumpWidget(const SizedBox());
    });
  }

  test('las categorías de cálculos especiales tienen pestaña', () {
    for (final c in [
      'Liquidos IV',
      'LÍQUIDOS IV',
      'Reposición de Sodio',
      'Reposición de HCO3',
    ]) {
      expect(pestanaDeCategoriaONull(c), isNotNull, reason: c);
    }
  });
}
