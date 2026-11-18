// lib/widgets/tabla_vital.dart
//
// Tabla única para las pantallas de signos vitales: mismo estilo en todas,
// columnas ajustadas al ancho (sin deslizar de lado) y la fila de la edad
// del paciente resaltada.
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_ui.dart';

const Color _tinta = Color(0xFF14212C);
const Color _gris = Color(0xFF5B6B78);
const Color _borde = Color(0xFFD3E3F3);
const Color _resaltado = Color(0xFFFFF4C2);
const Color _resaltadoBorde = Color(0xFFE0B100);

/// Corta el texto en líneas solo donde tiene sentido (antes de un
/// paréntesis o "+"), para no partir palabras ni números.
String _enLineas(String s) => s
    .replaceAll(RegExp(r'\s+\('), '\n(')
    .replaceAll(RegExp(r'\s+\+\s+'), ' +\n');

class TablaVital extends StatelessWidget {
  final IconData icono;
  final String titulo;

  /// Encabezados de columna; la primera es la edad.
  final List<String> columnas;

  /// Ancho relativo de cada columna.
  final List<double> anchos;
  final List<List<String>> filas;

  /// Índice de la fila que corresponde al paciente (o null).
  final int? filaPaciente;

  const TablaVital({
    super.key,
    required this.icono,
    required this.titulo,
    required this.columnas,
    required this.anchos,
    required this.filas,
    this.filaPaciente,
  }) : assert(columnas.length == anchos.length);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    TableRow encabezado() => TableRow(
      decoration: const BoxDecoration(color: AppUI.primaryBlue),
      children: [
        for (var i = 0; i < columnas.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            // Nunca partir una palabra: si no cabe, se achica.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: i == 0 ? Alignment.centerLeft : Alignment.center,
              child: Text(
                _enLineas(columnas[i]),
                textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );

    TableRow fila(int r) {
      final esPaciente = r == filaPaciente;
      final celdas = filas[r];
      return TableRow(
        decoration: BoxDecoration(
          color: esPaciente
              ? _resaltado
              : (r.isEven ? Colors.white : const Color(0xFFF5F8FC)),
        ),
        children: [
          for (var i = 0; i < celdas.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
              child: i == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _enLineas(celdas[i]),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _tinta,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (esPaciente)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _resaltadoBorde),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 12,
                                    color: Color(0xFF7A5A00),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    t.vtPatientRow,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7A5A00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  // Los valores nunca se parten ("102-120" en una línea).
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _enLineas(celdas[i]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: esPaciente
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: _tinta,
                        ),
                      ),
                    ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icono, color: AppUI.primaryBlue, size: 22),
              const SizedBox(width: 10),
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _borde),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Table(
                columnWidths: {
                  for (var i = 0; i < anchos.length; i++)
                    i: FlexColumnWidth(anchos[i]),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Color(0xFFE6EDF4)),
                ),
                children: [
                  encabezado(),
                  for (var r = 0; r < filas.length; r++) fila(r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nota informativa debajo de una tabla de signos vitales.
class NotaVital extends StatelessWidget {
  final String texto;
  final IconData icono;
  const NotaVital(this.texto, {super.key, this.icono = Icons.info_outline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppUI.softBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppUI.primaryBlue, size: 20),
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
    );
  }
}

/// Cuerpo estándar de una pantalla de signos vitales.
class PantallaVital extends StatelessWidget {
  final String tituloBarra;
  final List<Widget> children;
  const PantallaVital({
    super.key,
    required this.tituloBarra,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tituloBarra)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto gris pequeño (p. ej. aclaración de unidades).
class _Aclaracion extends StatelessWidget {
  final String texto;
  const _Aclaracion(this.texto);
  @override
  Widget build(BuildContext context) =>
      Text(texto, style: const TextStyle(fontSize: 12, color: _gris));
}

/// Expuesto para pantallas que quieran una línea de unidades bajo la tabla.
Widget aclaracionVital(String texto) => _Aclaracion(texto);

/// Una edad de la tabla de PAM: PA sistólica/diastólica y PAM, cada una
/// con mínima, media y máxima.
class FilaPam {
  final String edad;
  final List<String> paSisDia; // [mín, media, máx]
  final List<String> pam; // [mín, media, máx]
  const FilaPam(this.edad, this.paSisDia, this.pam);
}

/// Tabla de PAM como tarjetas (una por edad): las 7 columnas originales
/// no caben en un celular. Resalta la edad del paciente y, si la lista es
/// larga, baja automáticamente hasta ella.
class TablaPam extends StatefulWidget {
  final List<FilaPam> filas;
  final int? filaPaciente;
  const TablaPam({super.key, required this.filas, this.filaPaciente});

  @override
  State<TablaPam> createState() => _TablaPamState();
}

class _TablaPamState extends State<TablaPam> {
  final _clavePaciente = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.filaPaciente != null && widget.filas.length > 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _clavePaciente.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.25,
            duration: const Duration(milliseconds: 350),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget celda(String s, {required bool fuerte, TextAlign? align}) =>
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align == TextAlign.left
              ? Alignment.centerLeft
              : Alignment.center,
          child: Text(
            s.replaceAll(' / ', '/'),
            style: TextStyle(
              fontSize: fuerte ? 16 : 12.5,
              fontWeight: fuerte ? FontWeight.w900 : FontWeight.w600,
              color: fuerte ? _tinta : _gris,
            ),
          ),
        );

    Widget encabezado() => Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          const Expanded(flex: 11, child: SizedBox()),
          for (final c in [t.pamColMin, t.pamColMean, t.pamColMax])
            Expanded(
              flex: 10,
              child: Text(
                c,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppUI.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );

    Widget tarjeta(int i) {
      final f = widget.filas[i];
      final esPaciente = i == widget.filaPaciente;
      Widget linea(String etiqueta, List<String> v, bool fuerte) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              flex: 11,
              child: celda(etiqueta, fuerte: false, align: TextAlign.left),
            ),
            for (final x in v)
              Expanded(flex: 10, child: celda(x, fuerte: fuerte)),
          ],
        ),
      );

      return Container(
        key: esPaciente ? _clavePaciente : null,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: esPaciente ? _resaltado : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: esPaciente ? _resaltadoBorde : _borde,
            width: esPaciente ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  f.edad,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _tinta,
                  ),
                ),
                if (esPaciente) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _resaltadoBorde),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: Color(0xFF7A5A00),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          t.vtPatientRow,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7A5A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            linea(t.pamRowPam, f.pam, true),
            linea(t.pamRowSysDia, f.paSisDia, false),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppUI.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.pamCardTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppUI.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          encabezado(),
          for (var i = 0; i < widget.filas.length; i++) tarjeta(i),
        ],
      ),
    );
  }
}

/// Recuadro con las fórmulas de PAM.
class FormulasPam extends StatelessWidget {
  final String titulo;
  final List<String> lineas;
  const FormulasPam({super.key, required this.titulo, required this.lineas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppUI.softBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.functions, color: AppUI.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppUI.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final l in lineas)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: Color(0xFF33475B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarjeta de texto con título, del mismo estilo que las tablas.
class TarjetaVital extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<InlineSpan> texto;
  final String? pie;

  const TarjetaVital({
    super.key,
    required this.icono,
    required this.titulo,
    required this.texto,
    this.pie,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icono, color: AppUI.primaryBlue, size: 22),
              const SizedBox(width: 10),
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
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(children: texto),
            style: const TextStyle(fontSize: 15, height: 1.45, color: _tinta),
          ),
          if (pie != null) ...[
            const SizedBox(height: 10),
            Text(pie!, style: const TextStyle(fontSize: 12, color: _gris)),
          ],
        ],
      ),
    );
  }
}

/// Texto en negrita para usar dentro de [TarjetaVital].
TextSpan negrita(String s) => TextSpan(
  text: s,
  style: const TextStyle(fontWeight: FontWeight.w900),
);
