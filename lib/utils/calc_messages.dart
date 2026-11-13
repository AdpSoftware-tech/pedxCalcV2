import '../l10n/app_localizations.dart';

/// Códigos de mensaje que devuelven las calculadoras (sin contexto de idioma)
/// y que cada pantalla traduce con [CalcMsg.localize].
class CalcMsg {
  static const String needSodium = '@calc.needSodium';
  static const String needHco3 = '@calc.needHco3';
  static const String noSodiumDeficit = '@calc.noSodiumDeficit';
  static const String noHco3Deficit = '@calc.noHco3Deficit';
  static const String needAge = '@calc.needAge';

  /// Traduce un código; cualquier otro texto (p. ej. "30 ml") se devuelve igual.
  static String localize(String? raw, AppLocalizations t) {
    switch (raw) {
      case null:
        return t.commonNA;
      case needSodium:
        return t.calcNeedSodium;
      case needHco3:
        return t.calcNeedHco3;
      case noSodiumDeficit:
        return t.calcNoSodiumDeficit;
      case noHco3Deficit:
        return t.calcNoHco3Deficit;
      case needAge:
        return t.calcNeedAge;
      default:
        return raw;
    }
  }
}
