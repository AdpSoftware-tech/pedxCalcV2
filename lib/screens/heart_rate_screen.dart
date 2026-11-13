import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Frecuencia cardíaca normal en lactantes.
class HeartRateScreen extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const HeartRateScreen({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    // Pantalla de meses: 1–11 meses = fila de lactante (1–12 meses).
    return p.edadMeses > 0 ? 1 : null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.hrInfantAppBarTitle,
      children: [
        TablaVital(
          icono: Icons.favorite,
          titulo: t.vtCardTitle,
          columnas: [t.hrColAge, t.hrColAwake, t.hrColAsleep],
          anchos: const [1.6, 1, 1],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.hrInfantRowNeonate, '100-205', '90-160'],
            [t.hrInfantRowInfant, '100-190', '90-160'],
          ],
        ),
        NotaVital(t.hrNote),
      ],
    );
  }
}
