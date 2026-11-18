import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial normal e hipotensión en neonatos y lactantes.
class BloodPressureScreen extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const BloodPressureScreen({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    // Pantalla de meses: 1–11 meses = fila de lactante (1–12 meses).
    return p.edadMeses > 0 ? 3 : null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.bpNeoAppBarTitle,
      children: [
        TablaVital(
          icono: Icons.speed,
          titulo: t.vtCardTitle,
          columnas: [
            t.bpNeoColAge,
            t.bpNeoColSystolic,
            t.bpNeoColDiastolic,
            t.bpNeoColHypotensionSystolic,
          ],
          anchos: const [1.5, 1, 1, 1.1],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.bpNeoRowBirth12hLt1kg, '39-59', '16-36', '<40-50'],
            [t.bpNeoRowBirth12h3kg, '60-76', '31-45', '<50'],
            [t.bpNeoRowNeonate96h, '67-84', '35-53', '<60'],
            [t.bpNeoRowInfant1to12mo, '72-104', '37-56', '<70'],
          ],
        ),
        NotaVital(t.bpNeoNote),
      ],
    );
  }
}
