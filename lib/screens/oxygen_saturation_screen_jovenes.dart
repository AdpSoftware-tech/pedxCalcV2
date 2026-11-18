import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/tabla_vital.dart';

/// Saturación de oxígeno (texto explicativo).
class OxygenSaturationScreenJ extends StatelessWidget {
  const OxygenSaturationScreenJ({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.o2AppBarTitle,
      children: [
        TarjetaVital(
          icono: Icons.bubble_chart_outlined,
          titulo: t.o2CardTitle,
          texto: [
            TextSpan(text: '${t.o2Paragraph1}\n\n'),
            TextSpan(text: t.o2Paragraph2Part1),
            negrita(t.o2ThresholdBold),
            TextSpan(text: t.o2Paragraph2Part2),
            negrita(t.o2RespConditionBold),
            TextSpan(text: t.o2Or),
            negrita(t.o2CyanoticHeartBold),
          ],
        ),
        NotaVital(t.o2Note),
      ],
    );
  }
}
