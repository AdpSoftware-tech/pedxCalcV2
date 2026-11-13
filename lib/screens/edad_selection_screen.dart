import 'package:flutter/material.dart';
import 'package:mi_app/screens/paciente_data_screen.dart';
import 'package:mi_app/screens/paciente_data_meses_screen.dart';
import 'package:mi_app/l10n/app_localizations.dart';
import 'package:mi_app/theme/app_ui.dart';
import 'package:mi_app/widgets/language_toggle.dart';

class EdadSelectionScreen extends StatelessWidget {
  const EdadSelectionScreen({super.key});

  static const Color _softBorder = Color(0xFFD3E3F3);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // Pantalla raíz del flujo: el botón "atrás" no sale de aquí.
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.ageSelectTitle),
          automaticallyImplyLeading: false,
          actions: const [LanguageToggleButton(), SizedBox(width: 8)],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppUI.maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t.ageSelectQuestion,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppUI.primaryBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.ageSelectSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: Color(0xFF5B6B78),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _OptionCard(
                            key: const ValueKey('opt-anios'),
                            icon: Icons.child_care,
                            title: t.ageYearsTitle,
                            subtitle: t.ageYearsSubtitle,
                            badgeText: t.commonBadge,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PacienteDataScreen(
                                  isEdadAniosMode: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _OptionCard(
                            key: const ValueKey('opt-meses'),
                            icon: Icons.child_friendly,
                            title: t.ageMonthsTitle,
                            subtitle: t.ageMonthsSubtitle,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PacienteDataMesesScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Aclaración secundaria, debajo de las opciones.
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppUI.softBlueBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppUI.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.ageSelectNote,
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  const _OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppUI.primaryBlue.withAlpha((0.25 * 255).round()),
        ),
      ),
      shadowColor: Colors.black26,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppUI.softBlueBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppUI.primaryBlue, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wrap: si el título y la etiqueta no caben, la etiqueta
                    // baja de línea en vez de desbordarse.
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF14212C),
                          ),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppUI.softGreenBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFB7E4C7),
                              ),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Color(0xFF5B6B78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppUI.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}
