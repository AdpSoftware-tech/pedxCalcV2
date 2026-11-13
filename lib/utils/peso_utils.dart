/// Utilidades compartidas para la entrada de peso del paciente.
library;

/// Convierte texto a número aceptando coma o punto decimal
/// ("7,5" y "7.5" → 7.5). Devuelve null si no es un número.
double? parseDecimal(String? text) {
  if (text == null) return null;
  final normalized = text.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

/// Rangos de peso aceptados. Fuera de ellos se asume un error de tipeo
/// (p. ej. 220 en vez de 22), que multiplicaría todas las dosis.
class RangoPeso {
  final double min;
  final double max;
  const RangoPeso(this.min, this.max);

  bool contiene(double peso) => peso >= min && peso <= max;

  String get minTexto => _fmt(min);
  String get maxTexto => _fmt(max);

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

/// Lactantes de 1 a 11 meses.
const RangoPeso rangoPesoMeses = RangoPeso(1, 20);

/// Niños de 1 a 14 años.
const RangoPeso rangoPesoAnios = RangoPeso(3, 150);

/// Peso estimado para lactantes, igual que la tabla Excel "para APP"
/// (celda F7: =C7/2 + 4,5), es decir (meses + 9) / 2.
/// 1 mes → 5 kg · 6 meses → 7,5 kg · 11 meses → 10 kg.
double? pesoEstimadoMeses(int? meses) {
  if (meses == null || meses < 1 || meses > 11) return null;
  return meses / 2 + 4.5;
}

/// Peso estimado para niños de 1 a 14 años (fórmula existente de la app):
/// 1–4 años: 2 × edad + 8 · 5–14 años: 3 × edad + 3.
double? pesoEstimadoAnios(int? anios) {
  if (anios == null || anios < 1 || anios > 14) return null;
  return anios <= 4 ? anios * 2 + 8.0 : anios * 3 + 3.0;
}
