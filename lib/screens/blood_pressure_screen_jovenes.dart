import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Presión arterial normal e hipotensión de 1 a 15 años.
class BloodPressureScreenJ extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const BloodPressureScreenJ({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    final a = p.edadAnios;
    if (a < 1) return null;
    if (a <= 2) return 0;
    if (a <= 5) return 1;
    if (a <= 9) return 2;
    if (a <= 11) return 3;
    if (a <= 15) return 4;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.bpAppBarTitle,
      children: [
        TablaVital(
          icono: Icons.speed,
          titulo: t.vtCardTitle,
          columnas: [
            t.bpColAge,
            t.bpColSystolic,
            t.bpColDiastolic,
            t.bpColHypotensionSystolic,
          ],
          anchos: const [1.3, 1, 1, 1.3],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.bpRowAge1to2, '86-106', '42-63', t.notAvailable],
            [t.bpRowAge3to5, '89-112', '46-72', t.bpRowHypotensionFormula],
            [t.bpRowAge6to9, '97-115', '57-76', t.notAvailable],
            [t.bpRowAge10to11, '102-120', '61-80', t.notAvailable],
            [t.bpRowAge12to15, '110-131', '64-83', '<90'],
          ],
        ),
        NotaVital(t.bpNoteFormula),
      ],
    );
  }
}
