import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Frecuencia cardíaca normal de 1 a 15 años.
class HeartRateScreenJ extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const HeartRateScreenJ({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    final a = p.edadAnios;
    if (a < 1) return null;
    if (a <= 2) return 0;
    if (a <= 5) return 1;
    if (a <= 11) return 2;
    if (a <= 15) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.hrAppBarTitle,
      children: [
        TablaVital(
          icono: Icons.favorite,
          titulo: t.vtCardTitle,
          columnas: [t.hrColAge, t.hrColAwake, t.hrColAsleep],
          anchos: const [1.6, 1, 1],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.hrRowToddler, '98-140', '80-120'],
            [t.hrRowPreschool, '80-120', '65-100'],
            [t.hrRowSchoolAge, '75-118', '58-90'],
            [t.hrRowAdolescent, '60-100', '50-90'],
          ],
        ),
        NotaVital(t.hrNote),
      ],
    );
  }
}
