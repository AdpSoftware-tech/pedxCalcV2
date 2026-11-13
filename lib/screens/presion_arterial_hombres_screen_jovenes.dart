import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial y PAM por edad (años).
class PresionArterialHombresScreenJ extends StatelessWidget {
  /// Si se indica, se resalta (y se muestra) la fila de su edad.
  final Paciente? paciente;

  const PresionArterialHombresScreenJ({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    // Una fila por año, de 1 a 19 años.
    final a = p.edadAnios;
    return (a >= 1 && a <= 19) ? a - 1 : null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.bpMenTitle,
      children: [
        TablaPam(
          filaPaciente: _filaPaciente(),
          filas: [
            FilaPam(
              t.bpAge1Year,
              const ['81.4 / 44.0', '93.6 / 53.0', '105.8 / 62.0'],
              const ['56.5', '66.5', '76.6'],
            ),
            FilaPam(
              t.bpAge2Years,
              const ['84.2 / 47.9', '95.0 / 56.5', '105.8 / 65.1'],
              const ['60.1', '69.3', '78.7'],
            ),
            FilaPam(
              t.bpAge3Years,
              const ['80.8 / 44.9', '93.5 / 54.3', '106.2 / 63.7'],
              const ['56.9', '67.4', '77.9'],
            ),
            FilaPam(
              t.bpAge4Years,
              const ['78.7 / 44.5', '90.8 / 53.9', '102.9 / 63.3'],
              const ['55.9', '66.2', '76.5'],
            ),
            FilaPam(
              t.bpAge5Years,
              const ['83.4 / 47.7', '94.3 / 57.4', '105.2 / 67.1'],
              const ['59.6', '69.7', '79.8'],
            ),
            FilaPam(
              t.bpAge6Years,
              const ['86.1 / 48.5', '96.2 / 58.5', '106.3 / 68.5'],
              const ['61.1', '71.1', '81.1'],
            ),
            FilaPam(
              t.bpAge7Years,
              const ['87.4 / 50.5', '97.8 / 60.7', '108.2 / 70.9'],
              const ['62.8', '73.1', '83.3'],
            ),
            FilaPam(
              t.bpAge8Years,
              const ['88.7 / 51.6', '98.7 / 61.6', '108.7 / 71.6'],
              const ['64.1', '74.1', '84.1'],
            ),
            FilaPam(
              t.bpAge9Years,
              const ['90.6 / 52.6', '100.7 / 62.7', '110.1 / 72.6'],
              const ['65.3', '75.3', '85.1'],
            ),
            FilaPam(
              t.bpAge10Years,
              const ['91.4 / 54.1', '101.9 / 63.6', '112.4 / 73.1'],
              const ['66.5', '76.4', '86.2'],
            ),
            FilaPam(
              t.bpAge11Years,
              const ['92.4 / 53.6', '103.2 / 63.4', '114.0 / 73.2'],
              const ['66.5', '76.7', '86.8'],
            ),
            FilaPam(
              t.bpAge12Years,
              const ['95.0 / 55.8', '105.8 / 65.6', '116.6 / 75.4'],
              const ['68.9', '79.1', '88.9'],
            ),
            FilaPam(
              t.bpAge13Years,
              const ['95.2 / 54.7', '107.8 / 65.5', '120.4 / 76.3'],
              const ['68.2', '79.6', '91.1'],
            ),
            FilaPam(
              t.bpAge14Years,
              const ['95.2 / 54.7', '107.8 / 65.5', '120.4 / 76.3'],
              const ['68.2', '79.6', '91.1'],
            ),
            FilaPam(
              t.bpAge15Years,
              const ['97.2 / 55.3', '110.1 / 66.2', '123.0 / 77.1'],
              const ['69.3', '80.8', '92.4'],
            ),
            FilaPam(
              t.bpAge16Years,
              const ['100.5 / 55.2', '113.0 / 66.2', '125.5 / 77.2'],
              const ['70.3', '81.8', '93.3'],
            ),
            FilaPam(
              t.bpAge17Years,
              const ['102.4 / 56.3', '114.7 / 67.4', '127.0 / 78.5'],
              const ['71.7', '83.2', '94.7'],
            ),
            FilaPam(
              t.bpAge18Years,
              const ['105.4 / 59.8', '117.6 / 70.2', '129.8 / 80.6'],
              const ['75.1', '86.1', '97.1'],
            ),
            FilaPam(
              t.bpAge19Years,
              const ['106.3 / 61.8', '118.7 / 71.9', '131.1 / 82.0'],
              const ['76.6', '87.5', '98.4'],
            ),
          ],
        ),
        FormulasPam(
          titulo: t.bpFormulasTitle,
          lineas: [t.bpFormulaLine1, t.bpFormulaLine2, t.bpFormulaLine3],
        ),
      ],
    );
  }
}
