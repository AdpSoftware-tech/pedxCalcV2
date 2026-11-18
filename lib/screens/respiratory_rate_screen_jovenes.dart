import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Frecuencia respiratoria normal (1 a 15 años).
class RespiratoryRateScreenJ extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const RespiratoryRateScreenJ({super.key, this.paciente});

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
      tituloBarra: t.rrAppBarTitle,
      children: [
        TablaVital(
          icono: Icons.air,
          titulo: t.rrCardTitle,
          columnas: [t.rrTableHeaderAge, t.rrTableHeaderNormal],
          anchos: const [1.6, 1],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.rrAgeRow1, '22-37'],
            [t.rrAgeRow2, '20-28'],
            [t.rrAgeRow3, '18-25'],
            [t.rrAgeRow4, '12-20'],
          ],
        ),
        NotaVital(t.rrSourceNote, icono: Icons.menu_book_outlined),
      ],
    );
  }
}
