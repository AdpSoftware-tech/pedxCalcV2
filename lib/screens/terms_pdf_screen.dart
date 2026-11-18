import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../l10n/app_localizations.dart';

/// Muestra los Términos y Condiciones en PDF según el idioma de la app.
///
/// Archivos (dentro de la app, funcionan sin internet):
///   assets/terms/terminos_es.pdf  → español
///   assets/terms/terms_en.pdf     → inglés (también para otros idiomas)
class TermsPdfScreen extends StatelessWidget {
  /// Ruta fija del PDF; si es null se elige según el idioma (uso normal).
  final String? rutaPdf;

  const TermsPdfScreen({super.key, this.rutaPdf});

  static const Map<String, String> pdfPorIdioma = {
    'es': 'assets/terms/terminos_es.pdf',
    'en': 'assets/terms/terms_en.pdf',
  };

  /// Ruta del PDF para un código de idioma; inglés por defecto.
  static String rutaPara(String languageCode) =>
      pdfPorIdioma[languageCode] ?? pdfPorIdioma['en']!;

  Future<Uint8List> _cargarPdf(String ruta) async {
    final data = await rootBundle.load(ruta);
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final ruta =
        rutaPdf ?? rutaPara(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(t.termsPdfTitle)),
      body: FutureBuilder<Uint8List>(
        future: _cargarPdf(ruta),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorPdf(mensaje: t.termsPdfNotAvailable);
          }
          final bytes = snapshot.data!;
          return PdfPreview(
            build: (_) async => bytes,
            pdfFileName: ruta.split('/').last,
            // Es un documento fijo: no tiene sentido cambiar formato u orientación.
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            onError: (context, error) =>
                _ErrorPdf(mensaje: t.termsPdfNotAvailable),
          );
        },
      ),
    );
  }
}

class _ErrorPdf extends StatelessWidget {
  final String mensaje;
  const _ErrorPdf({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
