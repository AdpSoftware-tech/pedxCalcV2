import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/data/medicamento_data.dart';
import 'package:mi_app/data/medicamento_data_meses.dart';
import 'package:mi_app/data/menu_categorias.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/medicamentos_list_meses_screen.dart';
import 'package:mi_app/screens/select_medicamento_screen.dart';
import 'package:mi_app/utils/favoritos_store.dart';
import 'package:mi_app/widgets/menu_pestanas.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {String lang = 'es'}) => MaterialApp(
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

void main() {
  group('tabla categoría → pestaña', () {
    test('todas las categorías de meses tienen pestaña', () {
      final sinPestana = medicamentosMeses
          .map((m) => m.categoria)
          .toSet()
          .where((c) => pestanaDeCategoriaONull(c) == null)
          .toList();
      expect(sinPestana, isEmpty);
    });

    test('todas las categorías de años tienen pestaña', () {
      final sinPestana = allMedicamentos
          .map((m) => m.categoria)
          .toSet()
          .where((c) => pestanaDeCategoriaONull(c) == null)
          .toList();
      expect(sinPestana, isEmpty);
    });

    test('cambios pedidos por el cliente', () {
      expect(pestanaDeCategoria('Hipoglicemia'), MenuPestana.paro);
      expect(pestanaDeCategoria('Infusiones sedación'), MenuPestana.intubacion);
      expect(
        pestanaDeCategoria('Infusiones - Sedación'),
        MenuPestana.intubacion,
      );
      expect(MenuPestana.values.indexOf(MenuPestana.electrolitos), 6);
    });

    test('ninguna pestaña queda vacía', () {
      for (final lista in [medicamentosMeses, allMedicamentos]) {
        final usadas = lista.map((m) => pestanaDeCategoria(m.categoria));
        expect(usadas.toSet(), MenuPestana.values.toSet());
      }
    });

    test('variantes de escritura se normalizan', () {
      expect(
        pestanaDeCategoria('SNC  (crisis convulsivas)'),
        MenuPestana.otros,
      );
      expect(pestanaDeCategoria('paro cardiaco'), MenuPestana.paro);
    });
  });

  group('pantallas', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FavoritosStore.reiniciarParaTests();
    });

    Future<void> abrir(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(screen));
      await tester.pumpAndSettle();
    }

    for (final caso in [
      (
        'meses',
        () => MedicamentosListMesesScreen(
          paciente: Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 8),
        ),
      ),
      (
        'años',
        () => SelectMedicamentoScreen(
          paciente: Paciente(pesoKg: 20, edadAnios: 6, edadMeses: 0),
        ),
      ),
    ]) {
      testWidgets('${caso.$1}: muestra las 9 pestañas y filtra', (
        tester,
      ) async {
        await abrir(tester, caso.$2());
        expect(tester.takeException(), isNull);

        for (final p in MenuPestana.values) {
          expect(find.byKey(ValueKey('menu-${p.name}')), findsOneWidget);
        }

        // Elegir Anafilaxia: solo queda esa categoría.
        await tester.tap(find.byKey(const ValueKey('menu-anafilaxia')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('Anafilaxia')), findsOneWidget);
        expect(find.byKey(const ValueKey('Bradiarritmias')), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('${caso.$1}: favoritos', (tester) async {
        await abrir(tester, caso.$2());

        // Filtro sin favoritos → mensaje vacío.
        await tester.tap(find.byKey(const ValueKey('menu-favoritos')));
        await tester.pumpAndSettle();
        expect(find.textContaining('Aún no tienes favoritos'), findsOneWidget);

        // Volver, marcar el primer medicamento visible y filtrar otra vez.
        await tester.tap(find.byKey(const ValueKey('menu-favoritos')));
        await tester.pumpAndSettle();
        final estrella = find.byType(FavoritoButton).first;
        await tester.ensureVisible(estrella);
        await tester.tap(estrella);
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 3000));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('menu-favoritos')));
        await tester.pumpAndSettle();

        expect(find.textContaining('Aún no tienes favoritos'), findsNothing);
        expect(find.byIcon(Icons.star), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
