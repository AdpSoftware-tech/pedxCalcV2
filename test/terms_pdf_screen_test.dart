import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/screens/instrucciones_screen_with_terms.dart';
import 'package:mi_app/screens/terms_pdf_screen.dart';

Widget _app(Widget home, String lang) => MaterialApp(
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
  group('PDF según idioma', () {
    test('español → terminos_es.pdf', () {
      expect(TermsPdfScreen.rutaPara('es'), 'assets/terms/terminos_es.pdf');
    });
    test('inglés → terms_en.pdf', () {
      expect(TermsPdfScreen.rutaPara('en'), 'assets/terms/terms_en.pdf');
    });
    test('otro idioma → inglés', () {
      expect(TermsPdfScreen.rutaPara('fr'), 'assets/terms/terms_en.pdf');
    });
  });

  testWidgets('botón Términos abre la pantalla del PDF (español)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const InstruccionesScreenWithTerms(), 'es'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Términos'));
    // El visor de PDF anima mientras dibuja: avanzar fotogramas, no "settle".
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TermsPdfScreen), findsOneWidget);
    expect(find.text('Términos y Condiciones'), findsOneWidget);
  });

  testWidgets('en inglés el botón dice "Terms"', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const InstruccionesScreenWithTerms(), 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });

  testWidgets('sin el archivo PDF muestra un aviso claro', (tester) async {
    await tester.pumpWidget(
      _app(const TermsPdfScreen(rutaPdf: 'assets/terms/no_existe.pdf'), 'en'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The Terms and Conditions document is not available right now.',
      ),
      findsOneWidget,
    );
  });

  for (final lang in ['es', 'en']) {
    testWidgets('el PDF real de "$lang" está en la app y se carga', (
      tester,
    ) async {
      // El archivo existe dentro de la app (assets/terms/).
      final bytes = await tester.runAsync(
        () => rootBundle.load(TermsPdfScreen.rutaPara(lang)),
      );
      expect(bytes!.lengthInBytes, greaterThan(1000));
      // Cabecera de PDF: "%PDF"
      expect(String.fromCharCodes(bytes.buffer.asUint8List(0, 4)), '%PDF');

      await tester.pumpWidget(_app(const TermsPdfScreen(), lang));
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
      expect(find.byType(PdfPreview), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsNothing);
    });
  }
}
