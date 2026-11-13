// lib/widgets/language_toggle.dart
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppLocaleController;

/// Botón "🌐 ES / EN" para la barra superior: muestra el idioma actual y
/// al tocarlo cambia al otro.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final esEspanol = Localizations.localeOf(context).languageCode == 'es';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: t.languageSwitchTooltip,
        child: TextButton.icon(
          key: const ValueKey('lang-toggle'),
          onPressed: () =>
              AppLocaleController.set(Locale(esEspanol ? 'en' : 'es')),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withAlpha(38),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 36),
          ),
          icon: const Icon(Icons.language, size: 18),
          label: Text(
            esEspanol ? 'ES' : 'EN',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
