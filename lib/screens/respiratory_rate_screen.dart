import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/paciente.dart';
import '../widgets/tabla_vital.dart';

/// Frecuencia respiratoria normal (lactantes).
class RespiratoryRateScreen extends StatelessWidget {
  /// Si se indica, se resalta la fila de su edad.
  final Paciente? paciente;

  const RespiratoryRateScreen({super.key, this.paciente});

  int? _filaPaciente() {
    final p = paciente;
    if (p == null) return null;
    // Pantalla de meses: lactante = fila (<1 año).
    return p.edadMeses > 0 ? 0 : null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PantallaVital(
      tituloBarra: t.rrAppBarTitleWithUnit,
      children: [
        TablaVital(
          icono: Icons.air,
          titulo: t.rrCardTitle,
          columnas: [t.rrTableHeaderAge, t.rrTableHeaderNormal],
          anchos: const [1.6, 1],
          filaPaciente: _filaPaciente(),
          filas: [
            [t.rrAgeInfant, '30-53'],
            [t.rrAgeToddler, '22-37'],
          ],
        ),
        NotaVital(t.rrSourceNote, icono: Icons.menu_book_outlined),
      ],
    );
  }
}
