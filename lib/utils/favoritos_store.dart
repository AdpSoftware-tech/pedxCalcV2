// lib/utils/favoritos_store.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medicamento.dart';

/// Favoritos de medicamentos, guardados en el dispositivo.
///
/// Meses y años se guardan por separado ([ambito] = 'meses' / 'anios').
/// Muchos medicamentos tienen `id` vacío, así que la clave es
/// categoría + nombre (únicos dentro de cada lista).
class FavoritosStore {
  FavoritosStore._(this.ambito);

  static final Map<String, FavoritosStore> _instancias = {};

  /// Una instancia por ámbito, compartida por toda la app.
  factory FavoritosStore.de(String ambito) =>
      _instancias.putIfAbsent(ambito, () => FavoritosStore._(ambito));

  final String ambito;

  /// Claves de favoritos; las pantallas escuchan este notifier.
  final ValueNotifier<Set<String>> claves = ValueNotifier<Set<String>>({});

  bool _cargado = false;

  String get _prefKey => 'favoritos_$ambito';

  static String claveDe(Medicamento m) => '${m.categoria}|${m.nombre}';

  bool esFavorito(Medicamento m) => claves.value.contains(claveDe(m));

  Future<void> cargar() async {
    if (_cargado) return;
    _cargado = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      claves.value = (prefs.getStringList(_prefKey) ?? const []).toSet();
    } catch (_) {
      // Sin almacenamiento disponible: los favoritos viven solo en memoria.
    }
  }

  Future<void> alternar(Medicamento m) async {
    final nuevo = Set<String>.from(claves.value);
    final k = claveDe(m);
    if (!nuevo.remove(k)) nuevo.add(k);
    claves.value = nuevo;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, nuevo.toList()..sort());
    } catch (_) {
      // Ignorar: el cambio se mantiene en memoria.
    }
  }

  @visibleForTesting
  static void reiniciarParaTests() => _instancias.clear();
}
