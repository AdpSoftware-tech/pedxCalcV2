import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../data/menu_categorias.dart';
import '../models/paciente.dart';
import '../models/medicamento_calculado.dart';
import '../l10n/app_localizations.dart';
import '../i18n/med_i18n.dart';
import '../widgets/menu_pestanas.dart' show agruparPorPestana;

/// Reporte del paciente en PDF.
///
/// - Las letras van dentro de la app (assets/fonts): funciona sin internet.
/// - Medicamentos en el orden de las 9 pestañas del menú.
/// - Cada título de pestaña/categoría va pegado a su primer medicamento,
///   así nunca queda solo al final de una página.
class PrintablePatientDataScreen extends StatelessWidget {
  final Paciente paciente;
  final List<MedicamentoCalculado> medicamentosCalculados;

  /// true = peso estimado por edad; false = medido; null = no se sabe
  /// (no se muestra la etiqueta).
  final bool? esPesoEstimado;

  /// true = lactante (pantallas de meses). Si es null se deduce de la edad.
  final bool? esLactante;

  const PrintablePatientDataScreen({
    super.key,
    required this.paciente,
    required this.medicamentosCalculados,
    this.esPesoEstimado,
    this.esLactante,
  });

  static const _azul = PdfColor.fromInt(0xFF0E71C2);
  static const _tinta = PdfColor.fromInt(0xFF14212C);
  static const _gris = PdfColor.fromInt(0xFF5B6B78);
  static const _borde = PdfColor.fromInt(0xFFD3E3F3);
  static const _fondoSuave = PdfColor.fromInt(0xFFF5F8FC);
  static const _ambar = PdfColor.fromInt(0xFF7A4E00);
  static const _ambarFondo = PdfColor.fromInt(0xFFFFF4DC);

  // Anchos relativos de las columnas: medicamento · dosis · observaciones.
  static const _flexNombre = 30;
  static const _flexDosis = 26;
  static const _flexObs = 44;

  // ✅ Sanitiza caracteres que suelen romper el PDF (emoji/dashes)
  String _pdfSafe(String s, AppLocalizations t) {
    final v = s.trim();
    if (v.isEmpty) return t.commonDash;

    return v
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('✅', 'OK')
        .replaceAll('⚠️', '!')
        .replaceAll('🚫', '-');
  }

  /// Dosis en el mismo formato que la app: "2.2 ml · 22 mg".
  String _dosisToDisplay(MedicamentoCalculado med, AppLocalizations t) {
    final ds = med.dosisDisplayString.trim();
    if (ds.isNotEmpty && ds != 'N/A') return _pdfSafe(ds, t);

    final parts = <String>[
      for (final v in [
        med.dosisMlDisplay,
        med.dosisMgDisplay,
        med.dosisJuliosDisplay,
      ])
        if (v.trim().isNotEmpty && v != 'N/A') v.trim(),
    ];
    return parts.isEmpty ? t.commonNA : _pdfSafe(parts.join(' · '), t);
  }

  bool get _lactante =>
      esLactante ?? (paciente.edadAnios <= 0 && paciente.edadMeses > 0);

  String _ageDisplay(AppLocalizations t) {
    if (paciente.edadAnios > 0) {
      return '${paciente.edadAnios} ${t.printYearsUnit}';
    }
    if (paciente.edadMeses > 0) {
      return '${paciente.edadMeses} ${t.printMonthsUnit}';
    }
    return t.printAgeNotEntered;
  }

  static String _fmtKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);

  static PdfColor _pdf(Color c) => PdfColor.fromInt(c.toARGB32());

  // ---------- Piezas del PDF ----------

  pw.Widget _campo(String etiqueta, pw.Widget valor) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        etiqueta.toUpperCase(),
        style: const pw.TextStyle(fontSize: 7, color: _gris),
      ),
      pw.SizedBox(height: 2),
      valor,
    ],
  );

  pw.Widget _datosPaciente(AppLocalizations t, String fechaHora) {
    final grande = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: _tinta,
    );

    final pw.Widget? etiquetaPeso = switch (esPesoEstimado) {
      true => pw.Container(
        margin: const pw.EdgeInsets.only(top: 2),
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: pw.BoxDecoration(
          color: _ambarFondo,
          border: pw.Border.all(color: _ambar, width: 0.6),
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(
          t.printWeightEstimated,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: _ambar,
          ),
        ),
      ),
      false => pw.Text(
        t.printWeightMeasured,
        style: const pw.TextStyle(fontSize: 7, color: _gris),
      ),
      null => null,
    };

    pw.Widget linea(String etiqueta) => pw.Expanded(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            '$etiqueta:',
            style: const pw.TextStyle(fontSize: 8, color: _gris),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Container(
              height: 10,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _gris)),
              ),
            ),
          ),
        ],
      ),
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _fondoSuave,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borde),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _pdfSafe(t.printPatientDataTitle, t),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _azul,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: _campo(
                  t.printPatientAge,
                  pw.Text(_ageDisplay(t), style: grande),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: _campo(
                  t.printPatientWeight,
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${_fmtKg(paciente.pesoKg)} kg', style: grande),
                      ?etiquetaPeso,
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: _campo(
                  t.printPatientGroup,
                  pw.Text(
                    _pdfSafe(
                      _lactante ? t.printGroupInfant : t.printGroupChild,
                      t,
                    ),
                    style: const pw.TextStyle(fontSize: 9, color: _tinta),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: _campo(
                  t.printPatientAttended,
                  pw.Text(
                    fechaHora,
                    style: const pw.TextStyle(fontSize: 9, color: _tinta),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          // Para completar a mano: la app no guarda datos personales.
          pw.Row(
            children: [
              linea(t.printNameLine),
              pw.SizedBox(width: 16),
              linea(t.printRecordLine),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _encabezadoColumnas(AppLocalizations t) {
    pw.Widget celda(String s, int flex) => pw.Expanded(
      flex: flex,
      child: pw.Text(
        _pdfSafe(s, t),
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
    return pw.Container(
      color: _azul,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Row(
        children: [
          celda(t.printTableHeaderMedication, _flexNombre),
          celda(t.printTableHeaderDose, _flexDosis),
          celda(t.printTableHeaderNotes, _flexObs),
        ],
      ),
    );
  }

  pw.Widget _franjaPestana(MenuPestana p, AppLocalizations t) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _pdf(p.color),
        border: p.necesitaBorde ? pw.Border.all(color: _gris) : null,
      ),
      child: pw.Text(
        _pdfSafe(p.label(t).toUpperCase(), t),
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _pdf(p.texto),
        ),
      ),
    );
  }

  pw.Widget _tituloCategoria(String texto, MenuPestana p) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(6, 6, 6, 3),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: p.necesitaBorde ? _gris : _pdf(p.color),
            width: 3,
          ),
        ),
      ),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _tinta,
        ),
      ),
    );
  }

  pw.Widget _filaMed(MedicamentoCalculado med, AppLocalizations t, bool par) {
    return pw.Container(
      color: par ? PdfColors.white : _fondoSuave,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: _flexNombre,
            child: pw.Text(
              _pdfSafe(MedI18n.name(med.medicamentoOriginal, t), t),
              style: const pw.TextStyle(fontSize: 8.5, color: _tinta),
            ),
          ),
          pw.Expanded(
            flex: _flexDosis,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 6),
              child: pw.Text(
                _dosisToDisplay(med, t),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _tinta,
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: _flexObs,
            child: pw.Text(
              _pdfSafe(MedI18n.notes(med.medicamentoOriginal, t), t),
              style: const pw.TextStyle(fontSize: 8, color: _gris),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Documento ----------

  /// Letras del PDF, en este orden:
  /// 1. Roboto incluida en la app (funciona sin internet).
  /// 2. Roboto de Google Fonts (si la app se actualizó sin reiniciar).
  /// 3. Helvetica integrada en el PDF (sin acentos raros, pero nunca falla).
  static Future<pw.ThemeData> _temaPdf() async {
    try {
      final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      );
      return pw.ThemeData.withFont(base: regular, bold: bold);
    } catch (e) {
      debugPrint('PDF: letra incluida no disponible ($e)');
    }
    try {
      return pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      );
    } catch (e) {
      debugPrint('PDF: Google Fonts no disponible ($e)');
    }
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    AppLocalizations t,
  ) async {
    final pdf = pw.Document();

    final theme = await _temaPdf();

    final bytes = await rootBundle.load('assets/images/pedx.png');
    final logo = pw.MemoryImage(bytes.buffer.asUint8List());

    final agrupado = agruparPorPestana(
      medicamentosCalculados.map((m) => m.medicamentoOriginal),
      nombreCategoria: (c) => MedI18n.category(c, t),
      nombreMed: (m) => MedI18n.name(m, t),
    );
    final calculadoDe = {
      for (final m in medicamentosCalculados) m.medicamentoOriginal: m,
    };

    final fechaHora = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Cada título (pestaña/categoría) va en el MISMO bloque que su primer
    // medicamento: MultiPage no parte un bloque, así que nunca queda solo.
    final filas = <pw.Widget>[];
    agrupado.forEach((pestana, categorias) {
      var primeraDePestana = true;
      categorias.forEach((categoria, meds) {
        for (var i = 0; i < meds.length; i++) {
          final fila = _filaMed(calculadoDe[meds[i]]!, t, i.isEven);
          if (i == 0) {
            // Inseparable: el título y su primer medicamento van siempre
            // en la misma página.
            filas.add(
              pw.Inseparable(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (primeraDePestana) _franjaPestana(pestana, t),
                    _tituloCategoria(
                      _pdfSafe(MedI18n.category(categoria, t), t),
                      pestana,
                    ),
                    fila,
                  ],
                ),
              ),
            );
            primeraDePestana = false;
          } else {
            filas.add(fila);
          }
        }
      });
    });

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: format,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _pdfSafe(t.printPatientReportTitle, t),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _azul,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      // En las páginas siguientes se repite edad y peso.
                      context.pageNumber == 1
                          ? _pdfSafe(t.printAppSubtitle, t)
                          : '${t.printPatientAge}: ${_ageDisplay(t)} · '
                                '${t.printPatientWeight}: ${_fmtKg(paciente.pesoKg)} kg'
                                '${esPesoEstimado == true ? ' (${t.printWeightEstimated})' : ''}',
                      style: const pw.TextStyle(fontSize: 9, color: _gris),
                    ),
                  ],
                ),
                pw.Container(
                  width: 40,
                  height: 40,
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue100),
                  ),
                  child: pw.Image(logo),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: _borde, thickness: 1),
            if (context.pageNumber > 1) ...[
              _encabezadoColumnas(t),
              pw.SizedBox(height: 2),
            ],
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: _borde, thickness: 1),
            pw.SizedBox(height: 3),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${_pdfSafe(t.printGeneratedBy, t)} · ${_pdfSafe(t.printDisclaimer, t)}',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: _tinta,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  '${_pdfSafe(t.printPageLabel, t)} ${context.pageNumber} '
                  '${_pdfSafe(t.printPageOfLabel, t)} ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7, color: _gris),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 6),
          _datosPaciente(t, fechaHora),
          pw.SizedBox(height: 12),
          pw.Text(
            _pdfSafe(t.printMedsCalculatedTitle, t),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _azul,
            ),
          ),
          pw.SizedBox(height: 6),
          _encabezadoColumnas(t),
          ...filas,
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.printPatientReportTitle)),
      body: PdfPreview(
        build: (format) => _generatePdf(format, t),
        onError: (context, error) {
          // Deja el detalle en la consola para poder diagnosticarlo.
          debugPrint('PDF error: $error');
          return Center(child: Text(t.printPreviewError(error.toString())));
        },
      ),
    );
  }
}
