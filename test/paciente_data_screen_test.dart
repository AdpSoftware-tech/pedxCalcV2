import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/screens/paciente_data_screen.dart';
import 'package:mi_app/screens/paciente_data_meses_screen.dart';
import 'package:mi_app/screens/medicamentos_list_meses_screen.dart';
import 'package:mi_app/screens/select_medicamento_screen.dart';

Widget _app({Widget home = const PacienteDataScreen(isEdadAniosMode: true)}) =>
    MaterialApp(
      locale: Locale('en'),
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
  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
  }

  testWidgets('modo años: solo peso → continúa sin error', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), '22');
    await submit(tester);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(SelectMedicamentoScreen), findsOneWidget);
  });

  testWidgets('modo años: solo edad → continúa con peso estimado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(1), '5');
    await tester.pump();
    await submit(tester);
    expect(find.byType(SelectMedicamentoScreen), findsOneWidget);
  });

  testWidgets('modo años: sin peso ni edad → no continúa', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await submit(tester);
    expect(find.byType(SelectMedicamentoScreen), findsNothing);
  });

  testWidgets('modo años: peso con coma "22,5" → continúa', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), '22,5');
    await submit(tester);
    final screen = tester.widget<SelectMedicamentoScreen>(
      find.byType(SelectMedicamentoScreen),
    );
    expect(screen.paciente.pesoKg, 22.5);
  });

  testWidgets('modo años: 220 kg (error de tipeo) → no continúa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), '220');
    await submit(tester);
    expect(find.byType(SelectMedicamentoScreen), findsNothing);
    expect(find.textContaining('between 3 and 150 kg'), findsOneWidget);
  });

  group('modo meses', () {
    Future<void> setUpMeses(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(home: const PacienteDataMesesScreen()));
    }

    final edad = find.byKey(const ValueKey('campo-edad'));
    final peso = find.byKey(const ValueKey('campo-peso'));

    MedicamentosListMesesScreen lista(WidgetTester tester) =>
        tester.widget<MedicamentosListMesesScreen>(
          find.byType(MedicamentosListMesesScreen),
        );

    testWidgets('6 meses sin peso → estimado 7,5 kg (antes 21 kg)', (
      tester,
    ) async {
      await setUpMeses(tester);
      await tester.enterText(edad, '6');
      await tester.pump();
      expect(find.byKey(const ValueKey('peso-estimado')), findsOneWidget);
      await submit(tester);
      expect(lista(tester).paciente.pesoKg, 7.5);
      expect(lista(tester).paciente.edadMeses, 6);
      expect(lista(tester).esPesoEstimado, isTrue);
    });

    testWidgets('solo peso (sin edad) → continúa con ese peso', (tester) async {
      await setUpMeses(tester);
      await tester.enterText(peso, '8');
      await tester.pump();
      expect(find.byKey(const ValueKey('peso-real')), findsOneWidget);
      expect(find.textContaining('Without the age'), findsOneWidget);
      await submit(tester);
      expect(lista(tester).paciente.pesoKg, 8);
      expect(lista(tester).paciente.edadMeses, 0);
      expect(lista(tester).esPesoEstimado, isFalse);
    });

    testWidgets('peso "7,5" y edad → usa el peso real', (tester) async {
      await setUpMeses(tester);
      await tester.enterText(peso, '7,5');
      await tester.enterText(edad, '6');
      await tester.pump();
      await submit(tester);
      expect(lista(tester).paciente.pesoKg, 7.5);
      expect(lista(tester).paciente.edadMeses, 6);
      expect(lista(tester).esPesoEstimado, isFalse);
    });

    testWidgets('sin datos → aviso y no continúa', (tester) async {
      await setUpMeses(tester);
      await submit(tester);
      expect(find.byType(MedicamentosListMesesScreen), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('75 kg (error de tipeo) → no continúa', (tester) async {
      await setUpMeses(tester);
      await tester.enterText(peso, '75');
      await tester.enterText(edad, '6');
      await tester.pump();
      await submit(tester);
      expect(find.byType(MedicamentosListMesesScreen), findsNothing);
      expect(find.textContaining('between 1 and 20 kg'), findsOneWidget);
    });
  });

  testWidgets('encabezado de jóvenes: peso y edad en su sitio', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), '22,6');
    await tester.enterText(find.byType(TextFormField).at(1), '4');
    await tester.pump();
    await submit(tester);
    // Antes salía "4.0 kg · 22.6 years" (parámetros invertidos).
    expect(find.text('22.6 kg · 4 years'), findsOneWidget);
  });
}
