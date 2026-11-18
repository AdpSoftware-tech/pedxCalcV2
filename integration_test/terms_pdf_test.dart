import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/screens/terms_pdf_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final lang in ['es', 'en']) {
    testWidgets('PDF $lang se dibuja en la plataforma real', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const TermsPdfScreen(),
        ),
      );
      // Esperar hasta 15 s a que aparezcan las páginas rasterizadas.
      var paginas = 0;
      for (var i = 0; i < 60 && paginas == 0; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        paginas = find.byType(Image).evaluate().length;
      }
      debugPrint('RESULT $lang: imagenes=$paginas '
          'error=${find.byIcon(Icons.picture_as_pdf_outlined).evaluate().length} '
          'spinner=${find.byType(CircularProgressIndicator).evaluate().length}');
      expect(paginas, greaterThan(0));
    });
  }
}
