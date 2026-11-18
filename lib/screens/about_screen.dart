import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_ui.dart';
import '../widgets/language_toggle.dart';
import 'terms_pdf_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // ✅ Ajusta aquí tu versión (manual). Debe coincidir con `version` en
  // pubspec.yaml, que es la que ven las tiendas.
  static const String appVersion = '2.0.0';

  // ✅ Tu marca
  static const String companyName = 'A.P.D. Software Solutions';

  static const Color _softBorder = Color(0xFFD3E3F3);
  static const Color _ink = Color(0xFF14212C);
  static const Color _muted = Color(0xFF5B6B78);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final year = DateTime.now().year;
    final avisoTitulo = t.accordion9Title.replaceFirst(
      RegExp(r'^\s*\d+\.\s*'),
      '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutTitle),
        actions: const [LanguageToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppUI.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Encabezado: logo, nombre, versión =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0E71C2), Color(0xFF0A5A9C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/pedx.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Pedx Calc',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppUI.highlightGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t.proTag,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0B3D1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.aboutTagline,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: Color(0xFFDCEBFA),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${t.aboutVersionLabel} $appVersion',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _InfoCard(
                    title: t.purpose,
                    icon: Icons.favorite_rounded,
                    child: Text(
                      t.aboutPurposeText,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: _ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ===== Aviso clínico (mismo texto que en Instrucciones) =====
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2C4BC)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.health_and_safety_outlined,
                          color: Color(0xFFC62828),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                avisoTitulo,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t.accordion9Body,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7F1D1D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  _InfoCard(
                    title: t.aboutDocuments,
                    icon: Icons.description_outlined,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsPdfScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(t.termsPdfTitle),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppUI.primaryBlue,
                          side: const BorderSide(color: _softBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _InfoCard(
                    title: t.support,
                    icon: Icons.support_agent_rounded,
                    child: Text(
                      t.aboutSupportText,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: _ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _InfoCard(
                    title: t.developedBy,
                    icon: Icons.verified_rounded,
                    child: const Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    '© $year $companyName. ${t.rightsReserved}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AboutScreen._softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppUI.softBlueBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppUI.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AboutScreen._ink,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
