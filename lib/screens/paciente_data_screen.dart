import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/select_medicamento_screen.dart';
import 'package:mi_app/screens/instrucciones_screen_with_terms.dart';
import 'package:mi_app/theme/app_ui.dart';
import 'package:mi_app/widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../utils/peso_utils.dart';

/// Datos del paciente de 1 a 14 años.
///
/// Se puede continuar con solo el peso, solo la edad (peso estimado) o
/// ambos.
class PacienteDataScreen extends StatefulWidget {
  /// Se conserva por compatibilidad: la pantalla solo se usa en modo años.
  final bool isEdadAniosMode;

  const PacienteDataScreen({super.key, this.isEdadAniosMode = true});

  @override
  State<PacienteDataScreen> createState() => _PacienteDataScreenState();
}

class _PacienteDataScreenState extends State<PacienteDataScreen> {
  static const Color _softBorder = Color(0xFFD3E3F3);

  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _edadAniosController = TextEditingController();
  final _edadFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pesoController.addListener(_refrescarUI);
    _edadAniosController.addListener(_refrescarUI);
  }

  @override
  void dispose() {
    _pesoController.removeListener(_refrescarUI);
    _edadAniosController.removeListener(_refrescarUI);
    _pesoController.dispose();
    _edadAniosController.dispose();
    _edadFocus.dispose();
    super.dispose();
  }

  void _refrescarUI() {
    if (mounted) setState(() {});
  }

  // ---------- Estado derivado de los campos ----------

  double? get _pesoIngresado => parseDecimal(_pesoController.text);

  bool get _tienePesoValido {
    final p = _pesoIngresado;
    return p != null && rangoPesoAnios.contiene(p);
  }

  int? get _edadValida {
    final e = int.tryParse(_edadAniosController.text.trim());
    return (e != null && e >= 1 && e <= 14) ? e : null;
  }

  /// Peso estimado por edad; solo se usa si no hay peso real.
  double? get _pesoEstimadoKg =>
      _tienePesoValido ? null : pesoEstimadoAnios(_edadValida);

  String _labelBoton(AppLocalizations t) {
    if (_tienePesoValido) return t.patientBtnWithEnteredWeight;
    if (_pesoEstimadoKg != null) return t.patientBtnWithEstimatedWeight;
    return t.patientBtnCalculateDose;
  }

  static String _fmtKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);

  // ---------- Acción ----------

  void _calcularDosis(AppLocalizations t) {
    if (!_formKey.currentState!.validate()) return;

    final double? peso = _tienePesoValido ? _pesoIngresado : _pesoEstimadoKg;
    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.patientSnackNeedWeightOrAge),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMedicamentoScreen(
          // edadAnios 0 = edad no ingresada (se muestra N/A).
          paciente: Paciente(
            pesoKg: peso,
            edadAnios: _edadValida ?? 0,
            edadMeses: 0,
          ),
          esPesoEstimado: !_tienePesoValido,
        ),
      ),
    );
  }

  // ---------- UI ----------

  InputDecoration _decoracion({
    required String label,
    required String hint,
    required String helper,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, color: AppUI.primaryBlue),
      floatingLabelStyle: const TextStyle(color: AppUI.primaryBlue),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppUI.primaryBlue, width: 2),
      ),
    );
  }

  Widget _howItWorks(AppLocalizations t) {
    final titulo = t.patientHowItWorks.replaceAll(RegExp(r':\s*$'), '');
    final puntos = t.pdYearsHowBody
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*•\s*'), '').trim())
        .where((l) => l.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppUI.softBlueBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppUI.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppUI.primaryBlue,
                ),
              ),
            ],
          ),
          for (final p in puntos)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, left: 2, right: 8),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: AppUI.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 13.5,
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

  /// Recuadro con el peso que se va a usar (real o estimado).
  Widget _pesoResumen(AppLocalizations t) {
    final bool real = _tienePesoValido;
    final double? kg = real ? _pesoIngresado : _pesoEstimadoKg;
    if (kg == null) return const SizedBox.shrink();

    final Color fondo = real ? AppUI.softGreenBg : const Color(0xFFFFF4DC);
    final Color borde = real
        ? const Color(0xFFB7E4C7)
        : const Color(0xFFF2C66D);
    final Color texto = real
        ? const Color(0xFF1B5E20)
        : const Color(0xFF7A4E00);

    return Container(
      key: ValueKey(real ? 'peso-real' : 'peso-estimado'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            real ? Icons.check_circle : Icons.warning_amber_rounded,
            color: texto,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  real
                      ? t.pdRealWeight(_fmtKg(kg))
                      : t.pdEstimatedWeight(_fmtKg(kg)),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: texto,
                  ),
                ),
                if (!real)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      t.pdEstimatedHint,
                      style: TextStyle(fontSize: 13, color: texto),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.patientAppBarTitleYears),
          actions: [
            const LanguageToggleButton(),
            IconButton(
              tooltip: t.navInstructions,
              icon: const Icon(Icons.info_outline),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const InstruccionesScreenWithTerms(),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppUI.maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _softBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t.pdYearsTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppUI.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _howItWorks(t),
                            const SizedBox(height: 18),

                            // Peso (opcional)
                            TextFormField(
                              key: const ValueKey('campo-peso'),
                              controller: _pesoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _edadFocus.requestFocus(),
                              decoration: _decoracion(
                                label: t.pdWeightLabel,
                                hint: t.patientWeightHint,
                                helper: t.pdWeightHelperOptional,
                                icon: Icons.monitor_weight_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final peso = parseDecimal(value);
                                if (peso == null) {
                                  return t.patientValInvalidNumber;
                                }
                                if (!rangoPesoAnios.contiene(peso)) {
                                  return t.patientValWeightRange(
                                    rangoPesoAnios.minTexto,
                                    rangoPesoAnios.maxTexto,
                                  );
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Edad (opcional)
                            TextFormField(
                              key: const ValueKey('campo-edad'),
                              controller: _edadAniosController,
                              focusNode: _edadFocus,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _calcularDosis(t),
                              decoration: _decoracion(
                                label: t.pdAgeYearsLabel,
                                hint: t.patientAgeYearsHint,
                                helper: t.pdAgeYearsHelper,
                                icon: Icons.cake_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final edad = int.tryParse(value.trim());
                                if (edad == null || edad < 1 || edad > 14) {
                                  return t.patientValAgeRangeYears;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            _pesoResumen(t),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        key: const ValueKey('btn-calcular'),
                        onPressed: () => _calcularDosis(t),
                        icon: const Icon(Icons.calculate_outlined),
                        label: Text(
                          _labelBoton(t),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 17),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppUI.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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
    );
  }
}
