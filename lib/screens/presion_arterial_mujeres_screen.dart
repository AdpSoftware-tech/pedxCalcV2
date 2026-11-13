import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial y PAM por edad (meses).
class PresionArterialMujeresScreen extends StatelessWidget {
  /// Si se indica, se resalta (y se muestra) la fila de su edad.
  final Paciente? paciente;

  const PresionArterialMujeresScreen({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    // Filas: <7 días, 8–30 días, 1–5 meses, 6–11 meses.
    final m = p.edadMeses;
    if (m >= 1 && m <= 5) return 2;
    if (m >= 6 && m <= 11) return 3;
    return null;
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
              t.bpAgeLt7Days,
              const ['62.5 / 42.1', '71.8 / 50.5', '81.1 / 58.9'],
              const ['48.9', '57.6', '66.3'],
            ),
            FilaPam(
              t.bpAge8to30Days,
              const ['69.7 / 39.2', '81.7 / 50.7', '93.7 / 62.2'],
              const ['49.4', '61.1', '72.7'],
            ),
            FilaPam(
              t.bpAge1to5Months,
              const ['79.8 / 38.9', '92.0 / 49.5', '104.2 / 60.1'],
              const ['52.5', '63.7', '74.8'],
            ),
            FilaPam(
              t.bpAge6to11Months,
              const ['79.9 / 42.9', '94.5 / 52.5', '109.1 / 62.1'],
              const ['55.2', '66.5', '77.8'],
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
