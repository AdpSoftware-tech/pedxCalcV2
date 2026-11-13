import 'package:flutter/material.dart';
import 'package:mi_app/screens/edad_selection_screen.dart';
import 'package:mi_app/screens/about_screen.dart';
import 'package:mi_app/screens/terms_pdf_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_toggle.dart';
import 'package:mi_app/main.dart'; // para usar localeController

enum _TermsMenu { about, language }

class InstruccionesScreenWithTerms extends StatefulWidget {
  const InstruccionesScreenWithTerms({super.key});

  @override
  State<InstruccionesScreenWithTerms> createState() =>
      _InstruccionesScreenWithTermsState();
}

class _InstruccionesScreenWithTermsState
    extends State<InstruccionesScreenWithTerms> {
  bool _termsAccepted = false;
  static const _primaryBlue = Color.fromARGB(255, 14, 113, 194);

  static const _softBorder = Color(0xFFD3E3F3);

  void _setLocale(String code) => AppLocaleController.set(Locale(code));

  void _showLanguageDialog() {
    final t = AppLocalizations.of(context);
    final actual = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Widget opcion(String code, String titulo, String subtitulo) =>
            _LanguageTile(
              title: titulo,
              subtitle: subtitulo,
              selected: actual == code,
              onTap: () {
                _setLocale(code);
                Navigator.pop(ctx);
              },
            );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.languageDialogTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  opcion('es', 'Español', 'Spanish'),
                  const SizedBox(height: 8),
                  opcion('en', 'English', 'Inglés'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSecurityDialog() {
    final t = AppLocalizations.of(context);
    // TODO: contenido definitivo pendiente del cliente.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.securityButton),
        content: Text(t.securityPlaceholderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.modalClose),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    final t = AppLocalizations.of(context);

    return AppBar(
      title: Text(t.termsTitle),
      actions: [
        const LanguageToggleButton(),
        PopupMenuButton<_TermsMenu>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case _TermsMenu.about:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
                break;
              case _TermsMenu.language:
                _showLanguageDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _TermsMenu.about,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.info_outline),
                title: Text(t.menuAbout),
              ),
            ),
            PopupMenuItem(
              value: _TermsMenu.language,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.language),
                title: Text(t.menuLanguage),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickSummary(AppLocalizations t) {
    final titulo = t.quickSummaryTitle.replaceAll(RegExp(r':\s*$'), '');
    final puntos = t.quickSummaryBody
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*•\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: _primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final p in puntos)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, left: 4, right: 10),
                    child: Icon(Icons.circle, size: 6, color: _primaryBlue),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Color(0xFF33475B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _linkButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      key: key,
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: _primaryBlue),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: _softBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(0, 44),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _quickSummary(t),
                      InstructionAccordion(
                        title: t.accordion1Title,
                        content: t.accordion1Body,
                      ),
                      InstructionAccordion(
                        title: t.accordion3Title,
                        content: t.accordion3Body,
                      ),
                      InstructionAccordion(
                        title: t.accordion5Title,
                        content: t.accordion5Body,
                      ),
                      InstructionAccordion(
                        title: t.accordion7Title,
                        content: t.accordion7Body,
                      ),
                      InstructionAccordion(
                        title: t.accordion8Title,
                        content: t.accordion8Body,
                      ),
                      InstructionAccordion(
                        title: t.accordion9Title,
                        content: t.accordion9Body,
                        isImportant: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Zona fija inferior, compacta para no tapar las instrucciones.
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _softBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CheckboxListTile(
                          value: _termsAccepted,
                          onChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                          activeColor: _primaryBlue,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            t.termsAccept,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _primaryBlue,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _termsAccepted
                                ? () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EdadSelectionScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _primaryBlue.withAlpha(
                                (0.35 * 255).round(),
                              ),
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: Text(
                              t.btnContinue,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _linkButton(
                                key: const ValueKey('btn-terms'),
                                icon: Icons.description_outlined,
                                label: t.termsButton,
                                // Abre el PDF de Términos en el idioma activo.
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TermsPdfScreen(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _linkButton(
                                key: const ValueKey('btn-security'),
                                icon: Icons.shield_outlined,
                                label: t.securityButton,
                                onPressed: _showSecurityDialog,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  static const Color _primaryBlue = Color.fromARGB(255, 14, 113, 194);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF3FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? _primaryBlue : const Color(0xFFD3E3F3),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.language, color: _primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? _primaryBlue : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionAccordion extends StatefulWidget {
  final String title;
  final String content;
  final bool isImportant;

  const InstructionAccordion({
    super.key,
    required this.title,
    required this.content,
    this.isImportant = false,
  });

  @override
  State<InstructionAccordion> createState() => _InstructionAccordionState();
}

class _InstructionAccordionState extends State<InstructionAccordion> {
  bool _isExpanded = false;
  static const _primaryBlue = Color.fromARGB(255, 14, 113, 194);

  @override
  Widget build(BuildContext context) {
    final color = widget.isImportant ? Colors.red.shade700 : _primaryBlue;
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: widget.isImportant
              ? Colors.red.shade200
              : const Color(0xFFD3E3F3),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: widget.isImportant
                    ? Colors.red.shade700
                    : const Color(0xFF14212C),
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: color,
              size: 28,
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.isImportant
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        widget.content,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      widget.content,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black.withAlpha((0.75 * 255).round()),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
