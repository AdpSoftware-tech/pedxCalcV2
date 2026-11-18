import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial y PAM por edad (meses).
class PresionArterialHombresScreen extends StatelessWidget {
  /// Si se indica, se resalta (y se muestra) la fila de su edad.
  final Paciente? paciente;

  const PresionArterialHombresScreen({super.key, this.paciente});

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
      tituloBarra: t.bpMenTitle,
      children: [
        TablaPam(
          filaPaciente: _filaPaciente(),
          filas: [
            FilaPam(
              t.bpAgeLt7Days,
              const ['63.1 / 42.2', '72.5 / 51.1', '82.3 / 60.0'],
              const ['49.2', '58.3', '67.4'],
            ),
            FilaPam(
              t.bpAge8To30Days,
              const ['79.9 / 39.1', '82.0 / 50.3', '93.1 / 61.5'],
              const ['52.7', '60.9', '72.1'],
            ),
            FilaPam(
              t.bpAge1To5Months,
              const ['81.8 / 36.6', '93.0 / 47.8', '105.9 / 59.0'],
              const ['51.1', '62.9', '74.6'],
            ),
            FilaPam(
              t.bpAge6To11Months,
              const ['80.6 / 43.3', '95.4 / 53.3', '110.2 / 63.2'],
              const ['55.8', '67.3', '78.9'],
            ),
          ],
        ),
        FormulasPam(
          titulo: t.bpFormulasTitle,
          lineas: [t.bpFormulaLine1, t.bpFormulaLine2, t.bpFormulaLine3],
        ),
        NotaVital(t.bpMenNote),
      ],
    );
  }
}
