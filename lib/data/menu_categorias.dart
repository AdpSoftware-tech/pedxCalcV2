// lib/data/menu_categorias.dart
//
// Menú por pestañas de color, según la tabla aprobada por el cliente
// (archivo "Menu PedxCalc - respuesta(2).xlsx", nov. 2026).
//
// Para mover una categoría de pestaña, cambia solo el mapa
// `_pestanaPorCategoria`. El test `menu_categorias_test.dart` comprueba que
// todas las categorías de los datos tengan pestaña asignada.
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Las 9 pestañas, en el orden en que aparecen en la app.
enum MenuPestana {
  paro(Color(0xFFE02B20), Colors.white),
  intubacion(Color(0xFF6B2366), Colors.white),
  respiratorio(Color(0xFF4A7F2E), Colors.white),
  cardiovascular(Color(0xFF4FB0E8), Color(0xFF0B2233)),
  anafilaxia(Color(0xFFB5532A), Colors.white),
  shock(Colors.white, Color(0xFF14212C)),
  electrolitos(Color(0xFFE86BF0), Color(0xFF2A0A2C)),
  analgesia(Color(0xFFFFFF55), Color(0xFF2A2A00)),
  otros(Color(0xFF777777), Colors.white);

  /// Color de fondo de la pestaña (el de la tabla del cliente).
  final Color color;

  /// Color del texto sobre [color].
  final Color texto;

  const MenuPestana(this.color, this.texto);

  /// Shock es blanco: necesita borde para verse sobre fondo claro.
  bool get necesitaBorde => this == MenuPestana.shock;

  /// Color para textos/acentos sobre fondo claro (títulos, bordes).
  Color get acento {
    switch (this) {
      case MenuPestana.shock:
        return const Color(0xFF14212C);
      case MenuPestana.analgesia:
        return const Color(0xFF8A7A00);
      default:
        return color;
    }
  }

  String label(AppLocalizations t) {
    switch (this) {
      case MenuPestana.paro:
        return t.tabCardiacArrest;
      case MenuPestana.intubacion:
        return t.tabIntubation;
      case MenuPestana.respiratorio:
        return t.tabRespiratory;
      case MenuPestana.cardiovascular:
        return t.tabCardiovascular;
      case MenuPestana.anafilaxia:
        return t.tabAnaphylaxis;
      case MenuPestana.shock:
        return t.tabShock;
      case MenuPestana.electrolitos:
        return t.tabElectrolytes;
      case MenuPestana.analgesia:
        return t.tabAnalgesiaFever;
      case MenuPestana.otros:
        return t.tabOther;
    }
  }
}

/// Normaliza el texto de la categoría: minúsculas, sin acentos y sin
/// espacios repetidos (los datos tienen variantes como "Paro cardiaco" /
/// "Paro cardíaco" o "SNC  (crisis convulsivas)").
String normalizarCategoria(String s) {
  const conAcento = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinAcento = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    final i = conAcento.indexOf(ch);
    buffer.write(i >= 0 ? sinAcento[i] : ch);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Categoría (tal como está en los datos) → pestaña.
/// Incluye los nombres de meses y de años (no hay conflictos entre ellos).
const Map<String, MenuPestana> _pestanaPorCategoria = {
  // ---- Paro cardíaco
  'Paro cardíaco': MenuPestana.paro, // meses
  'Paro cardiaco': MenuPestana.paro, // años
  'Desfibrilación': MenuPestana.paro,
  'Hipoglicemia': MenuPestana.paro,

  // ---- Intubación
  'Parálisis muscular': MenuPestana.intubacion,
  'Infusiones sedación': MenuPestana.intubacion,
  'Infusiones - Sedación': MenuPestana.intubacion,
  'Secuencia rápida de intubación': MenuPestana.intubacion,
  'Sedación y amnesia': MenuPestana.intubacion,

  // ---- Respiratorio
  'Asma': MenuPestana.respiratorio,
  'Broncoespasmo/Asma': MenuPestana.respiratorio,
  'Bronquiolitis / Laringitis/Croup': MenuPestana.respiratorio,
  'Medicación específica según patología respiratoria':
      MenuPestana.respiratorio,
  'Cánulas de alto flujo': MenuPestana.respiratorio,

  // ---- Cardiovascular
  'Bradiarritmias': MenuPestana.cardiovascular,
  'Taquicardia supraventricular': MenuPestana.cardiovascular,
  'Taquicardia supraventrivular': MenuPestana.cardiovascular, // así en datos
  // ---- Anafilaxia
  'Anafilaxia': MenuPestana.anafilaxia,

  // ---- Shock
  'Shock': MenuPestana.shock,
  'Inotrópicos': MenuPestana.shock,
  'Líquids IV': MenuPestana.shock,
  'Líquidos endovenosos': MenuPestana.shock,
  'Líquidos IV': MenuPestana.shock, // cálculos especiales
  // ---- Electrolitos
  'Electrolitos': MenuPestana.electrolitos,
  'Calcio de mantenimiento': MenuPestana.electrolitos,
  'Hipocalcemia severa, hipermagnesemia ó intoxicación con bloqueadores canales de calcio':
      MenuPestana.electrolitos,
  'Hipocalcemia severa, Hipermagnesemia ó Intoxicación con bloqueadores de los canales de calcio':
      MenuPestana.electrolitos,
  'Hiponatremia aguda sintomática (convulsiones)': MenuPestana.electrolitos,
  'Reposición de K': MenuPestana.electrolitos,
  'Resposición de potasio': MenuPestana.electrolitos, // así en datos
  'Reposición de sodio': MenuPestana.electrolitos,
  'Reposición de HCO3': MenuPestana.electrolitos,

  // ---- Analgesia / fiebre
  'Analgesia': MenuPestana.analgesia,
  'Fiebre/Dolor': MenuPestana.analgesia,
  'Fiebre': MenuPestana.analgesia,

  // ---- Otros
  'Antibioticos': MenuPestana.otros,
  'Antídotos': MenuPestana.otros,
  'Revertir': MenuPestana.otros,
  'Endocrino / Renal': MenuPestana.otros,
  'Hemorragia severa incontrolable': MenuPestana.otros,
  'Hemorragia severa intratable': MenuPestana.otros,
  'Hipertensión intracraneal': MenuPestana.otros,
  'Status convulsivo': MenuPestana.otros,
  'Status epileptico': MenuPestana.otros,
  'SNC (crisis convulsivas)': MenuPestana.otros,
  'Vías centrales y drenajes pleurales': MenuPestana.otros,
};

final Map<String, MenuPestana> _pestanaNormalizada = {
  for (final e in _pestanaPorCategoria.entries)
    normalizarCategoria(e.key): e.value,
};

/// Pestaña de una categoría, o null si no está en la tabla.
MenuPestana? pestanaDeCategoriaONull(String categoria) =>
    _pestanaNormalizada[normalizarCategoria(categoria)];

/// Pestaña de una categoría. Lo que no esté en la tabla va a "Otros",
/// para que ningún medicamento desaparezca del menú.
MenuPestana pestanaDeCategoria(String categoria) =>
    pestanaDeCategoriaONull(categoria) ?? MenuPestana.otros;
