import 'package:flutter/material.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/utils/dosis_calculator_meses.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/screens/liquid_iv_detail_screen.dart';
import 'package:mi_app/screens/printable_patient_data_screen.dart';
import 'package:mi_app/models/medicamento_calculado.dart';

import '../l10n/app_localizations.dart';
import '../utils/calc_messages.dart';
import '../utils/peso_utils.dart';
import '../i18n/med_i18n.dart';
import '../widgets/calc_especial_widgets.dart';

// ====== DATA (IDs + categorías estables) ======

final List<Medicamento> hco3Medicamentos = [
  Medicamento(
    id: 'hco3_paciente',
    nombre: 'HCO3 del paciente',
    categoria: 'Reposición de HCO3',
    subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
    observaciones: 'Control de Na y Gases al finalizar',
  ),
  Medicamento(
    id: 'hco3_deficit',
    nombre: 'Déficit de HCO3',
    categoria: 'Reposición de HCO3',
    subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
    dosisActualMG: 'de Bicarbonato de Sodio al 1M (1mEq/mL)',
  ),
  Medicamento(
    id: 'hco3_vol_sg5',
    nombre: 'Volumen de SG5%',
    categoria: 'Reposición de HCO3',
    subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
    rangoDosisOriginal: 'a diluir déficit de HCO3',
    dosisActualMG: 'Pasar en 3h',
  ),
  Medicamento(
    id: 'hco3_vel_3h',
    nombre: 'Velocidad de Infusión a pasar en 3h',
    categoria: 'Reposición de HCO3',
    subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
    rangoDosisOriginal: 'a diluir déficit de HCO3',
    dosisActualMG: 'Pasar en 3h',
  ),
];

final List<Medicamento> sodioMedicamentos = [
  Medicamento(
    id: 'na_paciente',
    nombre: 'Sodio del paciente',
    categoria: 'Reposición de Sodio',
    subcategoria: '(Na < 130mEq/L)',
    observaciones: 'Control de Na y Osm al finalizar',
  ),
  Medicamento(
    id: 'na_deficit',
    nombre: 'Déficit de Sodio',
    categoria: 'Reposición de Sodio',
    subcategoria: '(Na < 130mEq/L)',
    dosisActualMG: 'de NaCl4M (4mEq/mL)',
  ),
  Medicamento(
    id: 'na_vol_sg5',
    nombre: 'Volumen de SG5%',
    categoria: 'Reposición de Sodio',
    subcategoria: '(Na < 130mEq/L)',
    dosisActualMG: 'Pasar en 3h',
  ),
  Medicamento(
    id: 'na_vel_3h',
    nombre: 'Velocidad de Infusión a pasar en 3h',
    categoria: 'Reposición de Sodio',
    subcategoria: '(Na < 130mEq/L)',
    dosisActualMG: 'Pasar en 3h',
  ),
  Medicamento(
    id: 'na_con_sf',
    nombre: 'Con SF',
    categoria: 'Reposición de Sodio',
    subcategoria: '(Na < 130mEq/L)',
    dosisActualMG: 'Pasar en 3h',
  ),
];

// ✅ Líquidos IV (meses) - categoría corregida y estable (sin typo)
final List<Medicamento> liquidosIVMedicamentos = [
  Medicamento(
    id: 'iv_sol_mixta',
    nombre: 'Solución mixta',
    categoria: 'Liquidos IV',
    rangoDosisOriginal: '(Requerimientos al 100%)',
    dosisActualMG: 'pasar en Bomba de Infusión continua en 24h IV',
    observaciones: '',
  ),
  Medicamento(
    id: 'iv_goteo',
    nombre: 'Goteo',
    categoria: 'Liquidos IV',
    observaciones: 'Requerimientos diarios',
    rangoDosisOriginal: '',
    dosisActualMG: '',
  ),
  Medicamento(
    id: 'iv_resultado',
    nombre: 'Resultado',
    categoria: 'Liquidos IV',
    dosisActualMG: 'Restar medicamentos',
    observaciones: '',
    rangoDosisOriginal: '',
  ),
  Medicamento(
    id: 'iv_goteo_aj',
    nombre: 'Goteo.',
    categoria: 'Liquidos IV',
    dosisActualMG: 'Restar infusiones',
    observaciones: 'Cálculo de líquidos por porcentaje',
    rangoDosisOriginal: '',
  ),
];

// ====== SCREEN ======

class CalculosEspecialesScreen extends StatefulWidget {
  final Paciente paciente;

  /// Para el reporte: peso estimado (true), medido (false) o no se sabe.
  final bool? esPesoEstimado;

  const CalculosEspecialesScreen({
    super.key,
    required this.paciente,
    this.esPesoEstimado,
  });

  @override
  State<CalculosEspecialesScreen> createState() =>
      _CalculosEspecialesScreenState();
}

class _CalculosEspecialesScreenState extends State<CalculosEspecialesScreen> {
  final TextEditingController _porcentajeController = TextEditingController();
  final TextEditingController _hco3Controller = TextEditingController();
  final TextEditingController _sodioController = TextEditingController();

  /// Porcentaje de requerimientos por defecto.
  static const double _porcentajeInicial = 40;

  double _porcentaje = _porcentajeInicial;

  // Sodio y HCO3 empiezan vacíos (0 = sin dato): nunca se muestran
  // déficits de un análisis que nadie ha ingresado.
  double _hco3Valor = 0;
  double _sodioValor = 0;

  @override
  void initState() {
    super.initState();

    _porcentajeController.text = _fmtPct(_porcentaje);

    _porcentajeController.addListener(() {
      setState(() {
        _porcentaje = parseDecimal(_porcentajeController.text) ?? 0.0;
      });
    });

    _hco3Controller.addListener(() {
      setState(() {
        _hco3Valor = parseDecimal(_hco3Controller.text) ?? 0.0;
      });
    });

    _sodioController.addListener(() {
      setState(() {
        _sodioValor = parseDecimal(_sodioController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _porcentajeController.dispose();
    _hco3Controller.dispose();
    _sodioController.dispose();
    super.dispose();
  }

  // ====== DISPLAY (lógica intacta, usa med.nombre original) ======

  String _getHco3Display(Medicamento medicamento) {
    final hco3Doses = DosisCalculatorMeses.calculateHco3Dosis(
      widget.paciente,
      _hco3Valor,
    );

    switch (medicamento.nombre) {
      case 'Déficit de HCO3':
        return CalcMsg.localize(
          hco3Doses['deficit_display']?.toString(),
          AppLocalizations.of(context),
        );
      case 'Volumen de SG5%':
        return CalcMsg.localize(
          hco3Doses['volumen_display']?.toString(),
          AppLocalizations.of(context),
        );
      case 'Velocidad de Infusión a pasar en 3h':
        return CalcMsg.localize(
          hco3Doses['velocidad_display']?.toString(),
          AppLocalizations.of(context),
        );
      default:
        return 'N/A';
    }
  }

  String _getSodioDisplay(Medicamento medicamento) {
    final sodioDoses = DosisCalculatorMeses.calculateSodioDosis(
      widget.paciente,
      _sodioValor,
    );

    switch (medicamento.nombre) {
      case 'Déficit de Sodio':
        return CalcMsg.localize(
          sodioDoses['deficit_display']?.toString(),
          AppLocalizations.of(context),
        );
      case 'Volumen de SG5%':
        return CalcMsg.localize(
          sodioDoses['volumen_display']?.toString(),
          AppLocalizations.of(context),
        );
      case 'Velocidad de Infusión a pasar en 3h':
        return CalcMsg.localize(
          sodioDoses['velocidad_display']?.toString(),
          AppLocalizations.of(context),
        );
      case 'Con SF':
        return CalcMsg.localize(
          sodioDoses['con_sf_display']?.toString(),
          AppLocalizations.of(context),
        );
      default:
        return 'N/A';
    }
  }

  String _getLiquidosIvDisplay(Medicamento medicamento) {
    final Map<String, dynamic> calculatedDoses =
        DosisCalculatorMeses.calculateDosis(
          widget.paciente,
          medicamento,
          porcentaje: _porcentaje,
        );

    if (calculatedDoses.containsKey('display_string')) {
      return (calculatedDoses['display_string'] ?? 'N/A').toString();
    }

    final double ml = (calculatedDoses['ml'] as double?) ?? 0.0;
    return '${DosisCalculatorMeses.formatDosis(ml)} ml';
  }

  bool _isTotalRow(Medicamento med) {
    final n = med.nombre.trim().toLowerCase();
    return n == 'resultado';
  }

  // ====== PRINT ======

  List<MedicamentoCalculado> _calcularTodasLasDosis() {
    final List<MedicamentoCalculado> list = [];

    for (final med in liquidosIVMedicamentos) {
      list.add(
        MedicamentoCalculado(
          medicamentoOriginal: med,
          dosisDisplayString: _getLiquidosIvDisplay(med),
        ),
      );
    }

    for (final med in hco3Medicamentos.skip(1)) {
      list.add(
        MedicamentoCalculado(
          medicamentoOriginal: med,
          dosisDisplayString: _getHco3Display(med),
        ),
      );
    }

    for (final med in sodioMedicamentos.skip(1)) {
      list.add(
        MedicamentoCalculado(
          medicamentoOriginal: med,
          dosisDisplayString: _getSodioDisplay(med),
        ),
      );
    }

    return list;
  }

  // ====== UI ======

  static String _fmtPct(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Títulos claros y traducidos para las filas (los nombres de datos se
  /// mantienen porque la lógica de cálculo depende de ellos).
  String _titulo(Medicamento med, AppLocalizations t) {
    switch (med.id) {
      case 'iv_sol_mixta':
        return t.specIvMixedSolution;
      case 'iv_goteo':
        return t.specIvDrip;
      case 'iv_resultado':
        return t.specialCalcTotalLabel;
      case 'iv_goteo_aj':
        return t.specIvDripAdjusted;
      case 'hco3_deficit':
        return t.specHco3Deficit;
      case 'hco3_vol_sg5':
        return t.specHco3Sg5Volume;
      case 'hco3_vel_3h':
      case 'na_vel_3h':
        return t.calcRate3h;
      case 'na_deficit':
        return t.specNaDeficit;
      case 'na_vol_sg5':
        return t.specNaSg5Volume;
      case 'na_con_sf':
        return t.specNaWithNs;
      default:
        return MedI18n.name(med, t);
    }
  }

  /// Limpia sodio y HCO3 y devuelve el porcentaje a su valor inicial.
  void _limpiar() {
    setState(() {
      _porcentajeController.text = _fmtPct(_porcentajeInicial);
      _hco3Controller.clear();
      _sodioController.clear();
    });
  }

  void _abrirDetalle(Medicamento med, {double? hco3, double? sodio}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiquidIVDetailScreen(
          medicamento: med,
          paciente: widget.paciente,
          esPesoEstimado: widget.esPesoEstimado,
          porcentajeLiquidos: (hco3 == null && sodio == null)
              ? _porcentaje
              : 0.0,
          hco3Valor: hco3,
          sodioValor: sodio,
        ),
      ),
    );
  }

  Widget _patientHeader(AppLocalizations t) {
    final meses = widget.paciente.edadMeses;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Color(0xFF5B6B78)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${t.patientHeaderPrefix}: ${widget.paciente.pesoKg.toStringAsFixed(1)} kg · ${meses > 0 ? '$meses ${t.patientHeaderMonthsUnit}' : t.commonNA}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF5B6B78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== BUILD ======

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.specialCalcMonthsTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: t.calcClearTooltip,
              onPressed: _limpiar,
            ),
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: t.printFullReport,
              onPressed: () {
                final meds = _calcularTodasLasDosis();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrintablePatientDataScreen(
                      paciente: widget.paciente,
                      esPesoEstimado: widget.esPesoEstimado,
                      esLactante: true,
                      medicamentosCalculados: meds,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            CalcInfoBanner(t.accordion4Body),
            _patientHeader(t),

            // ---- Los 3 datos juntos, para llenarlos rápido
            CalcSeccionCard(
              titulo: t.calcInputsTitle,
              icono: Icons.edit_note,
              children: [
                CalcInputField(
                  fieldKey: const ValueKey('input-porcentaje'),
                  etiqueta: t.calcPercentLabel,
                  controller: _porcentajeController,
                  unidad: '%',
                ),
                CalcNota(t.calcPercentGuide),
                CalcInputField(
                  fieldKey: const ValueKey('input-sodio'),
                  etiqueta: t.calcSodiumLabel,
                  controller: _sodioController,
                  unidad: 'mEq/L',
                  hint: '—',
                ),
                CalcInputField(
                  fieldKey: const ValueKey('input-hco3'),
                  etiqueta: t.calcHco3Label,
                  controller: _hco3Controller,
                  unidad: 'mEq/L',
                  hint: '—',
                  ultimo: true,
                ),
              ],
            ),

            // ---- Resultados
            CalcSeccionCard(
              titulo: t.sectionLiquidsIV,
              icono: Icons.water_drop_outlined,
              children: [
                for (final med in liquidosIVMedicamentos)
                  CalcResultRow(
                    titulo: _titulo(med, t),
                    valorCrudo: _getLiquidosIvDisplay(med),
                    destacado: _isTotalRow(med),
                    onTap: () => _abrirDetalle(med),
                  ),
              ],
            ),
            CalcSeccionCard(
              titulo: t.sectionSodium,
              icono: Icons.science_outlined,
              children: [
                for (final med in sodioMedicamentos.skip(1))
                  CalcResultRow(
                    titulo: _titulo(med, t),
                    valorCrudo: _getSodioDisplay(med),
                    onTap: () => _abrirDetalle(med, sodio: _sodioValor),
                  ),
              ],
            ),
            CalcSeccionCard(
              titulo: t.sectionHco3,
              icono: Icons.biotech_outlined,
              children: [
                for (final med in hco3Medicamentos.skip(1))
                  CalcResultRow(
                    titulo: _titulo(med, t),
                    valorCrudo: _getHco3Display(med),
                    onTap: () => _abrirDetalle(med, hco3: _hco3Valor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
