import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/tabla_vital.dart';

/// Temperatura normal por método de medición (no varía con la edad).
class TemperatureScreenJ extends StatelessWidget {
  const TemperatureScreenJ({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.tempAppBarTitleByMethod,
      children: [
        TablaVital(
          icono: Icons.thermostat,
          titulo: t.tempCardTitleNormalRangesByMethod,
          columnas: [t.tempTableHeaderMethod, t.tempTableHeaderNormal],
          anchos: const [1.4, 1],
          filas: [
            [t.tempMethodRectal, '36.6 - 38.0'],
            [t.tempMethodTympanic, '35.8 - 38.0'],
            [t.tempMethodOral, '35.5 - 37.5'],
            [t.tempMethodAxillary, '36.5 - 37.5'],
          ],
        ),
        TarjetaVital(
          icono: Icons.rule,
          titulo: t.tempNoteRangesDoNotVary,
          texto: [
            negrita('${t.tempGuideScreeningLabel} '),
            TextSpan(text: '${t.tempGuideScreeningText}\n'),
            negrita('${t.tempGuideDefinitiveLabel} '),
            TextSpan(text: t.tempGuideDefinitiveText),
          ],
          pie: t.tempReferenceCps2015,
        ),
      ],
    );
  }
}
