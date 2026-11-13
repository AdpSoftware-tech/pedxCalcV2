import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/screens/onboarding_screen.dart';

/// Recorre las 4 páginas del onboarding en varios tamaños de pantalla y
/// falla si alguna produce "RenderFlex overflowed" (franjas amarillas).
void main() {
  const sizes = {
    'ventana macOS baja': Size(780, 580),
    'macOS ancha': Size(1400, 900),
    'iPhone 15': Size(393, 852),
    'móvil pequeño': Size(320, 568),
  };

  sizes.forEach((name, size) {
    testWidgets('onboarding sin overflow en $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();

      for (var page = 0; page < 4; page++) {
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow en la página ${page + 1}',
        );
        if (page < 3) {
          await tester.fling(
            find.byType(PageView),
            Offset(-size.width, 0),
            2000,
          );
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
