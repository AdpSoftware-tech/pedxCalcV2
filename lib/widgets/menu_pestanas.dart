// lib/widgets/menu_pestanas.dart
//
// Piezas del menú por pestañas de color, compartidas por las pantallas de
// meses y de años.
import 'package:flutter/material.dart';

import '../data/menu_categorias.dart';
import '../l10n/app_localizations.dart';
import '../models/medicamento.dart';

/// Agrupa medicamentos: pestaña (en el orden del menú) → categoría → lista.
///
/// [nombreCategoria] y [nombreMed] dan el texto mostrado (traducido) y se
/// usan para ordenar alfabéticamente dentro de cada nivel.
Map<MenuPestana, Map<String, List<Medicamento>>> agruparPorPestana(
  Iterable<Medicamento> meds, {
  required String Function(String categoria) nombreCategoria,
  required String Function(Medicamento m) nombreMed,
}) {
  final tmp = <MenuPestana, Map<String, List<Medicamento>>>{};
  for (final m in meds) {
    final p = pestanaDeCategoria(m.categoria);
    tmp.putIfAbsent(p, () => {}).putIfAbsent(m.categoria, () => []).add(m);
  }

  final resultado = <MenuPestana, Map<String, List<Medicamento>>>{};
  for (final p in MenuPestana.values) {
    final cats = tmp[p];
    if (cats == null) continue;
    final claves = cats.keys.toList()
      ..sort((a, b) => nombreCategoria(a).compareTo(nombreCategoria(b)));
    resultado[p] = {
      for (final c in claves)
        c: (cats[c]!..sort((a, b) => nombreMed(a).compareTo(nombreMed(b)))),
    };
  }
  return resultado;
}

/// Botonera del menú: "Todas" + "Favoritos" y las 9 pestañas en 3 columnas.
class MenuPestanasBar extends StatelessWidget {
  /// Pestaña elegida; null = todas.
  final MenuPestana? seleccion;
  final bool soloFavoritos;
  final ValueChanged<MenuPestana?> onSeleccion;
  final ValueChanged<bool> onSoloFavoritos;

  const MenuPestanasBar({
    super.key,
    required this.seleccion,
    required this.soloFavoritos,
    required this.onSeleccion,
    required this.onSoloFavoritos,
  });

  static const Color _azul = Color.fromARGB(255, 14, 113, 194);
  static const Color _verde = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _BotonFiltro(
                  key: const ValueKey('menu-todas'),
                  texto: t.filterAll,
                  icono: Icons.apps,
                  seleccionado: seleccion == null,
                  color: _azul,
                  onTap: () => onSeleccion(null),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BotonFiltro(
                  key: const ValueKey('menu-favoritos'),
                  texto: t.filterFavorites,
                  icono: soloFavoritos ? Icons.star : Icons.star_border,
                  seleccionado: soloFavoritos,
                  color: _verde,
                  onTap: () => onSoloFavoritos(!soloFavoritos),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 6.0;
              final ancho = (c.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final p in MenuPestana.values)
                    SizedBox(
                      width: ancho,
                      child: _BotonPestana(
                        key: ValueKey('menu-${p.name}'),
                        pestana: p,
                        seleccionada: seleccion == p,
                        atenuada: seleccion != null && seleccion != p,
                        onTap: () => onSeleccion(seleccion == p ? null : p),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BotonFiltro extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;

  const _BotonFiltro({
    super.key,
    required this.texto,
    required this.icono,
    required this.seleccionado,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? color.withAlpha(38) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withAlpha(seleccionado ? 170 : 70),
          width: seleccionado ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: seleccionado ? color : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonPestana extends StatelessWidget {
  final MenuPestana pestana;
  final bool seleccionada;
  final bool atenuada;
  final VoidCallback onTap;

  const _BotonPestana({
    super.key,
    required this.pestana,
    required this.seleccionada,
    required this.atenuada,
    required this.onTap,
  });

  /// Una sola palabra ("Cardiovascular") se achica para caber en una línea
  /// en vez de partirse a la mitad; varias palabras pueden usar 2 líneas.
  Widget _etiqueta(String texto) {
    final estilo = TextStyle(
      color: pestana.texto,
      fontWeight: FontWeight.w800,
      fontSize: 13,
      height: 1.1,
    );
    if (!texto.contains(RegExp(r'[\s/]'))) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(texto, maxLines: 1, style: estilo),
      );
    }
    return Text(
      texto,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: estilo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final BorderSide borde;
    if (seleccionada) {
      borde = const BorderSide(color: Colors.black87, width: 3);
    } else if (pestana.necesitaBorde) {
      borde = const BorderSide(color: Color(0xFFB0BCC8));
    } else {
      borde = BorderSide.none;
    }

    return Semantics(
      selected: seleccionada,
      button: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: atenuada ? 0.55 : 1,
        child: Material(
          color: pestana.color,
          elevation: seleccionada ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borde,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Center(child: _etiqueta(pestana.label(t))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Franja de color con el nombre de la pestaña (vista "Todas").
class PestanaHeader extends StatelessWidget {
  final MenuPestana pestana;
  const PestanaHeader({super.key, required this.pestana});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: pestana.color,
          borderRadius: BorderRadius.circular(10),
          border: pestana.necesitaBorde
              ? Border.all(color: const Color(0xFFB0BCC8))
              : null,
        ),
        child: Text(
          pestana.label(t).toUpperCase(),
          style: TextStyle(
            color: pestana.texto,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Encabezado de submenú (categoría) con la barra del color de su pestaña.
class CategoriaHeader extends StatelessWidget {
  final String texto;
  final MenuPestana pestana;
  const CategoriaHeader({
    super.key,
    required this.texto,
    required this.pestana,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 20,
            decoration: BoxDecoration(
              color: pestana.necesitaBorde ? pestana.acento : pestana.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: pestana.acento,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estrella para marcar/desmarcar un favorito.
class FavoritoButton extends StatelessWidget {
  final bool esFavorito;
  final VoidCallback onPressed;
  const FavoritoButton({
    super.key,
    required this.esFavorito,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: esFavorito ? t.favRemove : t.favAdd,
      icon: Icon(
        esFavorito ? Icons.star : Icons.star_border,
        color: esFavorito ? const Color(0xFFF2A900) : Colors.black38,
        size: 24,
      ),
    );
  }
}

/// Mensaje cuando el filtro de favoritos no tiene nada que mostrar.
class FavoritosVacio extends StatelessWidget {
  const FavoritosVacio({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        t.favEmpty,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54, fontSize: 15),
      ),
    );
  }
}
