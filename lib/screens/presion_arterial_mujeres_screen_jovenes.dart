import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial y PAM por edad (años).
class PresionArterialMujeresScreenJ extends StatelessWidget {
  /// Si se indica, se resalta (y se muestra) la fila de su edad.
  final Paciente? paciente;

  const PresionArterialMujeresScreenJ({super.key, this.paciente});

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
      tituloBarra: t.bpWomenTitle,
      children: [
        TablaPam(
          filaPaciente: _filaPaciente(),
          filas: [
            FilaPam(
              t.bpAge1y,
              const ['80.2 / 43.2', '93.0 / 52.4', '105.8 / 61.6'],
              const ['55.5', '65.9', '76.3'],
            ),
            FilaPam(
              t.bpAge2y,
              const ['83.7 / 48.2', '94.6 / 57.0', '105.5 / 65.8'],
              const ['60.1', '69.5', '79.1'],
            ),
            FilaPam(
              t.bpAge3y,
              const ['79.9 / 45.3', '92.6 / 55.1', '105.3 / 64.9'],
              const ['56.8', '67.6', '78.4'],
            ),
            FilaPam(
              t.bpAge4y,
              const ['77.6 / 45.3', '90.7 / 54.5', '103.8 / 63.7'],
              const ['56.1', '66.6', '77.1'],
            ),
            FilaPam(
              t.bpAge5y,
              const ['83.5 / 47.4', '94.1 / 57.3', '104.7 / 67.2'],
              const ['59.4', '69.6', '79.7'],
            ),
            FilaPam(
              t.bpAge6y,
              const ['84.9 / 49.1', '95.5 / 59.3', '106.1 / 69.5'],
              const ['61.1', '71.4', '81.7'],
            ),
            FilaPam(
              t.bpAge7y,
              const ['86.1 / 49.4', '96.4 / 59.7', '106.7 / 70.0'],
              const ['61.6', '71.9', '82.2'],
            ),
            FilaPam(
              t.bpAge8y,
              const ['88.0 / 50.9', '98.3 / 61.0', '108.6 / 71.1'],
              const ['63.3', '73.4', '83.6'],
            ),
            FilaPam(
              t.bpAge9y,
              const ['89.4 / 52.5', '100.2 / 62.7', '111.0 / 72.9'],
              const ['64.8', '75.2', '85.6'],
            ),
            FilaPam(
              t.bpAge10y,
              const ['90.9 / 53.2', '101.8 / 63.1', '112.7 / 73.0'],
              const ['65.8', '76.1', '86.2'],
            ),
            FilaPam(
              t.bpAge11y,
              const ['93.5 / 54.4', '104.6 / 64.5', '115.7 / 74.6'],
              const ['67.4', '77.9', '88.3'],
            ),
            FilaPam(
              t.bpAge12y,
              const ['96.0 / 57.4', '107.5 / 67.1', '119.0 / 76.8'],
              const ['70.3', '80.6', '90.7'],
            ),
            FilaPam(
              t.bpAge13y,
              const ['95.1 / 56.7', '107.2 / 67.4', '119.3 / 78.1'],
              const ['69.5', '80.7', '91.8'],
            ),
            FilaPam(
              t.bpAge14y,
              const ['95.1 / 56.7', '107.2 / 67.4', '119.3 / 78.1'],
              const ['69.5', '80.7', '91.8'],
            ),
            FilaPam(
              t.bpAge15y,
              const ['96.0 / 57.0', '107.8 / 67.6', '119.6 / 78.2'],
              const ['70.1', '81.1', '92.1'],
            ),
            FilaPam(
              t.bpAge16y,
              const ['96.1 / 56.0', '107.5 / 66.2', '118.9 / 76.4'],
              const ['69.4', '80.1', '90.6'],
            ),
            FilaPam(
              t.bpAge17y,
              const ['97.9 / 56.3', '109.1 / 67.0', '120.3 / 77.7'],
              const ['70.2', '81.1', '91.9'],
            ),
            FilaPam(
              t.bpAge18y,
              const ['98.8 / 57.5', '109.9 / 67.6', '121.0 / 77.7'],
              const ['71.3', '81.7', '92.1'],
            ),
            FilaPam(
              t.bpAge19y,
              const ['99.1 / 57.0', '110.0 / 67.4', '120.9 / 77.8'],
              const ['71.1', '81.6', '92.2'],
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
