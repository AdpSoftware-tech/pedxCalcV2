import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/blood_pressure_screen.dart';
import 'package:mi_app/screens/blood_pressure_screen_jovenes.dart';
import 'package:mi_app/screens/heart_rate_screen.dart';
import 'package:mi_app/screens/heart_rate_screen_jovenes.dart';
import 'package:mi_app/screens/oxygen_saturation_screen.dart';
import 'package:mi_app/screens/oxygen_saturation_screen_jovenes.dart';
import 'package:mi_app/screens/presion_arterial_hombres_screen.dart';
import 'package:mi_app/screens/presion_arterial_hombres_screen_jovenes.dart';
import 'package:mi_app/screens/presion_arterial_mujeres_screen.dart';
import 'package:mi_app/screens/presion_arterial_mujeres_screen_jovenes.dart';
import 'package:mi_app/screens/respiratory_rate_screen.dart';
import 'package:mi_app/screens/respiratory_rate_screen_jovenes.dart';
import 'package:mi_app/screens/temperature_screen.dart';
import 'package:mi_app/screens/temperature_screen_jovenes.dart';

void main() {
  final pantallas = <Widget>[
    const HeartRateScreen(),
    const HeartRateScreenJ(),
    const RespiratoryRateScreen(),
    const RespiratoryRateScreenJ(),
    const BloodPressureScreen(),
    const BloodPressureScreenJ(),
    const TemperatureScreen(),
    const TemperatureScreenJ(),
    const OxygenSaturationScreen(),
    const OxygenSaturationScreenJ(),
    const PresionArterialMujeresScreen(),
    const PresionArterialMujeresScreenJ(),
    const PresionArterialHombresScreen(),
    const PresionArterialHombresScreenJ(),
  ];

  for (final w in pantallas) {
    for (final lang in ['es', 'en']) {
      testWidgets('${w.runtimeType} ($lang) abre sin errores en 320 px', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
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
            home: w,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  group('fila del paciente resaltada', () {
    Future<void> abrir(WidgetTester tester, Widget w) async {
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
          home: w,
        ),
      );
      await tester.pumpAndSettle();
    }

    Paciente anios(int a) => Paciente(pesoKg: 20, edadAnios: a, edadMeses: 0);

    testWidgets('FC años: 6 años → "6–11 años"', (tester) async {
      await abrir(tester, HeartRateScreenJ(paciente: anios(6)));
      expect(find.text('Paciente'), findsOneWidget);
      final fila = find.ancestor(
        of: find.text('Paciente'),
        matching: find.byType(Column),
      );
      expect(
        find.descendant(of: fila.first, matching: find.textContaining('6–11')),
        findsOneWidget,
      );
    });

    testWidgets('PA años: 10 años → "10-11 años"', (tester) async {
      await abrir(tester, BloodPressureScreenJ(paciente: anios(10)));
      final fila = find.ancestor(
        of: find.text('Paciente'),
        matching: find.byType(Column),
      );
      expect(
        find.descendant(of: fila.first, matching: find.textContaining('10')),
        findsWidgets,
      );
    });

    testWidgets('sin edad → nada resaltado', (tester) async {
      await abrir(tester, HeartRateScreenJ(paciente: anios(0)));
      expect(find.text('Paciente'), findsNothing);
      await abrir(tester, const HeartRateScreenJ());
      expect(find.text('Paciente'), findsNothing);
    });

    testWidgets('meses: lactante → fila 1–12 meses', (tester) async {
      await abrir(
        tester,
        HeartRateScreen(
          paciente: Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 6),
        ),
      );
      expect(find.text('Paciente'), findsOneWidget);
    });
  });

  testWidgets('PAM años: 6 años resaltado y visible', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
        home: PresionArterialHombresScreenJ(
          paciente: Paciente(pesoKg: 22, edadAnios: 6, edadMeses: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paciente'), findsOneWidget);
    // La tarjeta del paciente quedó dentro de la pantalla (baja sola).
    final y = tester.getCenter(find.text('Paciente')).dy;
    expect(y, inInclusiveRange(0, 844));
    expect(find.text('71.1'), findsOneWidget); // PAM media, 6 años
  });
}
