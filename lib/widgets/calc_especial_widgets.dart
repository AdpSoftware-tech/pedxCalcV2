// lib/widgets/calc_especial_widgets.dart
//
// Piezas visuales de "Cálculos especiales", compartidas por meses y años:
// una tarjeta por cálculo con su dato de entrada y sus resultados juntos.
import 'package:flutter/material.dart';

import '../theme/app_ui.dart';
import '../utils/peso_utils.dart';

const Color _softBorder = Color(0xFFD3E3F3);
const Color _ink = Color(0xFF14212C);
const Color _muted = Color(0xFF5B6B78);

/// Verde oscuro de resultados (mismo que la lista de medicamentos).
const Color calcDoseGreen = Color(0xFF1B7F3B);

/// Tarjeta de una sección: título, entrada opcional y filas de resultado.
class CalcSeccionCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const CalcSeccionCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                color: AppUI.softBlueBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(icono, color: AppUI.primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppUI.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo numérico con su etiqueta a la izquierda y la unidad dentro.
class CalcInputField extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final String unidad;
  final String? hint;
  final Key? fieldKey;

  /// El último campo cierra el teclado; los demás pasan al siguiente.
  final bool ultimo;

  const CalcInputField({
    super.key,
    required this.etiqueta,
    required this.controller,
    required this.unidad,
    this.hint,
    this.fieldKey,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: TextField(
              key: fieldKey,
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: ultimo
                  ? TextInputAction.done
                  : TextInputAction.next,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppUI.primaryBlue,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                suffixText: unidad,
                suffixStyle: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F8FC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppUI.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nota pequeña (p. ej. guía de porcentajes) dentro de una tarjeta.
class CalcNota extends StatelessWidget {
  final String texto;
  const CalcNota(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.lightbulb_outline, size: 16, color: _muted),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 12.5, color: _muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de resultado: título a la izquierda, valor + unidad a la derecha.
///
/// Normaliza solo la presentación: "ml"/"cc" → "mL", volúmenes sin
/// decimales y velocidades con 1 decimal. Si el valor no es numérico
/// (p. ej. "Ingresa el sodio del paciente") se muestra como aviso.
class CalcResultRow extends StatelessWidget {
  final String titulo;
  final String valorCrudo;
  final bool destacado;
  final VoidCallback onTap;

  const CalcResultRow({
    super.key,
    required this.titulo,
    required this.valorCrudo,
    required this.onTap,
    this.destacado = false,
  });

  /// Separa número y unidad y los formatea. null si no es numérico.
  static ({String valor, String unidad})? formatear(String crudo) {
    final m = RegExp(
      r'^\s*(-?[\d.,]+)\s*(ml/h|mL/h|ml|mL|cc|mEq/L|mg|%)?\s*$',
      caseSensitive: false,
    ).firstMatch(crudo);
    if (m == null) return null;
    final numero = parseDecimal(m.group(1));
    if (numero == null) return null;

    final u = (m.group(2) ?? '').toLowerCase();
    final esVelocidad = u == 'ml/h';
    final unidad = switch (u) {
      'ml/h' => 'mL/h',
      'ml' || 'cc' => 'mL',
      'meq/l' => 'mEq/L',
      _ => m.group(2) ?? '',
    };
    final decimales = esVelocidad ? 1 : (unidad == 'mL' ? 0 : 1);
    var texto = numero.toStringAsFixed(decimales);
    if (texto.contains('.')) {
      texto = texto.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return (valor: texto, unidad: unidad);
  }

  @override
  Widget build(BuildContext context) {
    final f = formatear(valorCrudo);

    final bool sinDato =
        valorCrudo.trim().isEmpty || valorCrudo.trim().toUpperCase() == 'N/A';
    final Widget valor = f == null
        ? Expanded(
            child: Text(
              sinDato ? '—' : valorCrudo,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: sinDato ? 18 : 13,
                fontWeight: FontWeight.w600,
                color: sinDato ? _muted : const Color(0xFF8A5A00),
              ),
            ),
          )
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: f.valor,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: calcDoseGreen,
                  ),
                ),
                if (f.unidad.isNotEmpty)
                  TextSpan(
                    text: ' ${f.unidad}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: calcDoseGreen,
                    ),
                  ),
              ],
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: destacado ? const Color(0xFFEFF8F1) : const Color(0xFFF7F9FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: destacado ? const Color(0xFFB7E4C7) : Colors.transparent,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: destacado ? FontWeight.w900 : FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                valor,
                const Icon(Icons.chevron_right, color: AppUI.primaryBlue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recuadro informativo azul de la parte superior.
class CalcInfoBanner extends StatelessWidget {
  final String texto;
  const CalcInfoBanner(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppUI.softBlueBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _softBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppUI.primaryBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: Color(0xFF33475B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
