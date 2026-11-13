// lib/widgets/vitales_menu.dart
//
// Menú de Signos vitales / PAM: ventana centrada con ícono y descripción
// corta en cada opción.
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_ui.dart';

class VitalOpcion {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final Future<void> Function() abrir;

  const VitalOpcion({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.abrir,
  });
}

/// Muestra el menú. Al volver de una tabla se reabre el mismo menú, para
/// poder consultar varias seguidas.
Future<void> mostrarMenuVitales(
  BuildContext context, {
  required String titulo,
  required String subtitulo,
  required IconData icono,
  required List<VitalOpcion> opciones,
}) async {
  final elegida = await showDialog<VitalOpcion>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _MenuVitales(
        titulo: titulo,
        subtitulo: subtitulo,
        icono: icono,
        opciones: opciones,
      ),
    ),
  );
  if (elegida == null || !context.mounted) return;

  await elegida.abrir();
  if (!context.mounted) return;
  await mostrarMenuVitales(
    context,
    titulo: titulo,
    subtitulo: subtitulo,
    icono: icono,
    opciones: opciones,
  );
}

class _MenuVitales extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final List<VitalOpcion> opciones;

  const _MenuVitales({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.opciones,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          // Desplazable: en celulares pequeños las 5 opciones no caben.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icono, color: AppUI.primaryBlue, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF14212C),
                            ),
                          ),
                          Text(
                            subtitulo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5B6B78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: const Color(0xFF5B6B78),
                      tooltip: t.modalClose,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final o in opciones) ...[
                  _OpcionTile(
                    opcion: o,
                    onTap: () => Navigator.pop(context, o),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionTile extends StatelessWidget {
  final VitalOpcion opcion;
  final VoidCallback onTap;

  const _OpcionTile({required this.opcion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE3EAF2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: opcion.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(opcion.icono, color: opcion.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opcion.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF14212C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      opcion.subtitulo,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF5B6B78),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppUI.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}
