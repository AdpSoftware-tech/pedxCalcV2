// lib/screens/calculos_especiales_jovenes_screen.dart
import 'package:flutter/material.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/utils/dosis_calculator_jovenes.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/screens/printable_patient_data_screen.dart';
import 'package:mi_app/models/medicamento_calculado.dart';
import 'package:mi_app/screens/calculos_jovenes_detail_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/calc_messages.dart';
import '../utils/peso_utils.dart';
import '../widgets/calc_especial_widgets.dart';

// ====== WRAPPER interno (ID estable + med) ======
class _SpecMed {
  final String id; // ID estable para i18n
  final Medicamento med;
  const _SpecMed(this.id, this.med);
}

// ====== IDS (estables) ======
// sodio
const _sidPaciente = 'sodio_paciente';
const _sidDeficit = 'sodio_deficit';
const _sidVolSG5 = 'sodio_vol_sg5';
const _sidConSf = 'sodio_con_sf';
const _sidVelInf = 'sodio_vel_inf';

// hco3
const _hidPaciente = 'hco3_paciente';
const _hidDeficit = 'hco3_deficit';
const _hidVolSG5 = 'hco3_vol_sg5';
const _hidVelInf = 'hco3_vel_inf';

// líquidos IV
const _lidSolMixta = 'liq_sol_mixta';
const _lidPorcentajeInfo = 'liq_porcentaje_info';
const _lidResultado = 'liq_resultado';
const _lidGoteo = 'liq_goteo';
const _lidGoteoAj = 'liq_goteo_aj';

// ====== DATA (id estable EN el Medicamento también) ======

final List<_SpecMed> sodioMedicamentos = [
  _SpecMed(
    _sidPaciente,
    Medicamento(
      id: _sidPaciente,
      nombre: 'Sodio del paciente',
      categoria: 'REPOSICION DE SODIO (Na <130mEq/L)',
      observaciones: 'Control de Na y Osm al finalizar',
    ),
  ),
  _SpecMed(
    _sidDeficit,
    Medicamento(
      id: _sidDeficit,
      nombre: 'Déficit de Sodio',
      categoria: 'REPOSICION DE SODIO (Na <130mEq/L)',
      observaciones: 'de NaCl4M (4mEq/mL)',
    ),
  ),
  _SpecMed(
    _sidVolSG5,
    Medicamento(
      id: _sidVolSG5,
      nombre: 'Volumen de SG5%',
      categoria: 'REPOSICION DE SODIO (Na <130mEq/L)',
      observaciones: 'Pasar en 3h',
    ),
  ),
  _SpecMed(
    _sidConSf,
    Medicamento(
      id: _sidConSf,
      nombre: 'Con SF',
      categoria: 'REPOSICION DE SODIO (Na <130mEq/L)',
      observaciones: 'Pasar en 3h',
    ),
  ),
  _SpecMed(
    _sidVelInf,
    Medicamento(
      id: _sidVelInf,
      nombre: 'Velocidad de Infusión',
      categoria: 'REPOSICION DE SODIO (Na <130mEq/L)',
      observaciones: 'Pasar en 3h (ml/h)',
    ),
  ),
];

final List<_SpecMed> hco3Medicamentos = [
  _SpecMed(
    _hidPaciente,
    Medicamento(
      id: _hidPaciente,
      nombre: 'HCO3 del paciente',
      categoria: 'Reposición de HCO3',
      subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
    ),
  ),
  _SpecMed(
    _hidDeficit,
    Medicamento(
      id: _hidDeficit,
      nombre: 'Déficit de HCO3',
      categoria: 'Reposición de HCO3',
      subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
      dosisActualMG: 'de Bicarbonato de Sodio al 1M (1mEq/mL)',
    ),
  ),
  _SpecMed(
    _hidVolSG5,
    Medicamento(
      id: _hidVolSG5,
      nombre: 'Volumen de SG5% a diluir déficit de HCO3',
      categoria: 'Reposición de HCO3',
      subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
      rangoDosisOriginal: 'a diluir déficit de HCO3',
      dosisActualMG: 'Pasar en 3h',
    ),
  ),
  _SpecMed(
    _hidVelInf,
    Medicamento(
      id: _hidVelInf,
      nombre: 'Velocidad de Infusión.',
      categoria: 'Reposición de HCO3',
      subcategoria: '(pH < 7,2; HCO3 < 8); Nunca mezclar con Calcio',
      rangoDosisOriginal: 'a diluir déficit de HCO3',
      dosisActualMG: 'Pasar en 3h',
    ),
  ),
];

final List<_SpecMed> liquidosIVMedicamentos = [
  _SpecMed(
    _lidSolMixta,
    Medicamento(
      id: _lidSolMixta,
      nombre: 'Solución mixta mantenimiento',
      categoria: 'LÍQUIDOS IV',
      observaciones:
          '< 10 kg (100cc/kg), 10-20 kg (50cc/kg), > 20 kg (20cc/kg)',
    ),
  ),
  _SpecMed(
    _lidPorcentajeInfo,
    Medicamento(
      id: _lidPorcentajeInfo,
      nombre: 'Calculo de Porcentaje',
      categoria: 'LÍQUIDOS IV',
      SituacionesEspeciales:
          'Riesgo SIADH: 80%, CAF/VMA:60-70%, LRA + NVO: 45%, LRA + VO: 30%',
    ),
  ),
  _SpecMed(
    _lidResultado,
    Medicamento(
      id: _lidResultado,
      nombre: 'Resultado',
      categoria: 'LÍQUIDOS IV',
    ),
  ),
  _SpecMed(
    _lidGoteo,
    Medicamento(id: _lidGoteo, nombre: 'Goteo', categoria: 'LÍQUIDOS IV'),
  ),
  _SpecMed(
    _lidGoteoAj,
    Medicamento(id: _lidGoteoAj, nombre: 'Goteo.', categoria: 'LÍQUIDOS IV'),
  ),
];

// ====== SCREEN ======

class CalculosEspecialesJovenesScreen extends StatefulWidget {
  final Paciente paciente;

  /// Para el reporte: peso estimado (true), medido (false) o no se sabe.
  final bool? esPesoEstimado;

  const CalculosEspecialesJovenesScreen({
    super.key,
    required this.paciente,
    this.esPesoEstimado,
  });

  @override
  State<CalculosEspecialesJovenesScreen> createState() =>
      _CalculosEspecialesJovenesScreenState();
}

class _CalculosEspecialesJovenesScreenState
    extends State<CalculosEspecialesJovenesScreen> {
  final TextEditingController _sodioController = TextEditingController();
  final TextEditingController _hco3Controller = TextEditingController();
  final TextEditingController _liquidosIvController = TextEditingController();

  /// Porcentaje de requerimientos por defecto.
  static const double _porcentajeInicial = 100;

  // Sodio y HCO3 empiezan vacíos (0 = sin dato): nunca se muestran
  // déficits de un análisis que nadie ha ingresado.
  double _sodioValor = 0;
  double _hco3Valor = 0;
  double _liquidosIvValor = _porcentajeInicial;

  @override
  void initState() {
    super.initState();

    _liquidosIvController.text = _fmtPct(_liquidosIvValor);

    _sodioController.addListener(() {
      setState(() => _sodioValor = parseDecimal(_sodioController.text) ?? 0);
    });
    _hco3Controller.addListener(() {
      setState(() => _hco3Valor = parseDecimal(_hco3Controller.text) ?? 0);
    });
    _liquidosIvController.addListener(() {
      setState(() {
        _liquidosIvValor = parseDecimal(_liquidosIvController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _sodioController.dispose();
    _hco3Controller.dispose();
    _liquidosIvController.dispose();
    super.dispose();
  }

  // ====== i18n label por ID (UI) ======
  // Si no existe la key, regresa el nombre original en español.
  String _uiLabelForId(_SpecMed item, AppLocalizations t) {
    try {
      switch (item.id) {
        // sodio
        case _sidPaciente:
          return t.specNaPatient;
        case _sidDeficit:
          return t.specNaDeficit;
        case _sidVolSG5:
          return t.specNaSg5Volume;
        case _sidConSf:
          return t.specNaWithNs;
        case _sidVelInf:
          return t.calcRate3h;

        // hco3
        case _hidPaciente:
          return t.specHco3Patient;
        case _hidDeficit:
          return t.specHco3Deficit;
        case _hidVolSG5:
          return t.specHco3Sg5Volume;
        case _hidVelInf:
          return t.calcRate3h;

        // líquidos
        case _lidSolMixta:
          return t.specIvMixedSolution;
        case _lidPorcentajeInfo:
          return t.specIvPercentInfoTitle;
        case _lidResultado:
          return t.specialCalcTotalLabel;
        case _lidGoteo:
          return t.specIvDrip;
        case _lidGoteoAj:
          return t.specIvDripAdjusted;

        default:
          return item.med.nombre;
      }
    } catch (_) {
      return item.med.nombre;
    }
  }

  // ====== DISPLAY HELPERS ======

  String _getLiquidosIvDisplay(_SpecMed item) {
    final liquidosIvDoses = DosisCalculatorJovenes.calculateLiquidosIvDosis(
      widget.paciente.pesoKg,
      _liquidosIvValor,
    );

    switch (item.id) {
      case _lidSolMixta:
        return liquidosIvDoses['solucion_mixta'] ?? 'N/A';
      case _lidResultado:
        return liquidosIvDoses['resultado'] ?? 'N/A';
      case _lidGoteo:
        return liquidosIvDoses['goteo_ml_h'] ?? 'N/A';
      case _lidGoteoAj:
        return liquidosIvDoses['goteo_ml_h_ajustado'] ?? 'N/A';
      default:
        return 'N/A';
    }
  }

  String _getSodioDisplay(_SpecMed item) {
    final sodioDoses = DosisCalculatorJovenes.calculateSodioDosis(
      widget.paciente.pesoKg,
      _sodioValor,
    );

    switch (item.id) {
      case _sidDeficit:
        return CalcMsg.localize(
          sodioDoses['deficit_display'],
          AppLocalizations.of(context),
        );
      case _sidVolSG5:
        return CalcMsg.localize(
          sodioDoses['volumen_display'],
          AppLocalizations.of(context),
        );
      case _sidConSf:
        return CalcMsg.localize(
          sodioDoses['con_sf_display'],
          AppLocalizations.of(context),
        );
      case _sidVelInf:
        return CalcMsg.localize(
          sodioDoses['velocidad_display'],
          AppLocalizations.of(context),
        );
      default:
        return 'N/A';
    }
  }

  String _getHco3Display(_SpecMed item) {
    final hco3Doses = DosisCalculatorJovenes.calculateHco3Dosis(
      widget.paciente.pesoKg,
      _hco3Valor,
    );

    switch (item.id) {
      case _hidDeficit:
        return CalcMsg.localize(
          hco3Doses['deficit_display'],
          AppLocalizations.of(context),
        );
      case _hidVolSG5:
        return CalcMsg.localize(
          hco3Doses['volumen_display'],
          AppLocalizations.of(context),
        );
      case _hidVelInf:
        return CalcMsg.localize(
          hco3Doses['velocidad_display'],
          AppLocalizations.of(context),
        );
      default:
        return 'N/A';
    }
  }

  // ====== PRINT ======

  List<MedicamentoCalculado> _calcularTodasLasDosis() {
    final List<MedicamentoCalculado> list = [];

    for (final item in liquidosIVMedicamentos) {
      if (item.id != _lidPorcentajeInfo) {
        list.add(
          MedicamentoCalculado(
            medicamentoOriginal: item.med,
            dosisDisplayString: _getLiquidosIvDisplay(item),
          ),
        );
      }
    }

    for (final item in hco3Medicamentos.skip(1)) {
      list.add(
        MedicamentoCalculado(
          medicamentoOriginal: item.med,
          dosisDisplayString: _getHco3Display(item),
        ),
      );
    }

    for (final item in sodioMedicamentos.skip(1)) {
      list.add(
        MedicamentoCalculado(
          medicamentoOriginal: item.med,
          dosisDisplayString: _getSodioDisplay(item),
        ),
      );
    }

    return list;
  }

  // ====== UI ======

  static String _fmtPct(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Limpia sodio y HCO3 y devuelve el porcentaje a su valor inicial.
  void _limpiar() {
    setState(() {
      _liquidosIvController.text = _fmtPct(_porcentajeInicial);
      _sodioController.clear();
      _hco3Controller.clear();
    });
  }

  void _abrirDetalle(_SpecMed item, String tipo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalculosJovenesDetailScreen(
          paciente: widget.paciente,
          esPesoEstimado: widget.esPesoEstimado,
          medicamento: item.med,
          sodioValor: _sodioValor,
          hco3Valor: _hco3Valor,
          liquidosIvValor: _liquidosIvValor,
          calculoType: tipo, // interno
        ),
      ),
    );
  }

  Widget _patientHeader(AppLocalizations t) {
    final weight = widget.paciente.pesoKg.toStringAsFixed(1);
    final isYears = widget.paciente.edadAnios > 0;
    final sinEdad =
        widget.paciente.edadAnios <= 0 && widget.paciente.edadMeses <= 0;
    final ageValue = sinEdad
        ? t.commonNA
        : isYears
        ? widget.paciente.edadAnios.toString()
        : widget.paciente.edadMeses.toString();
    final ageUnit = sinEdad
        ? ''
        : isYears
        ? t.specialCalcYearsUnit
        : t.specialCalcMonthsUnit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Color(0xFF5B6B78)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.specialCalcPatientHeader(weight, ageValue, ageUnit).trim(),
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
          title: Text(t.specialCalcTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: t.calcClearTooltip,
              onPressed: _limpiar,
            ),
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: t.specialCalcPrintTooltip,
              onPressed: () {
                final meds = _calcularTodasLasDosis();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrintablePatientDataScreen(
                      paciente: widget.paciente,
                      esPesoEstimado: widget.esPesoEstimado,
                      esLactante: false,
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
                  controller: _liquidosIvController,
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
              titulo: t.specialCalcSectionLiquids,
              icono: Icons.water_drop_outlined,
              children: [
                for (final item in liquidosIVMedicamentos)
                  if (item.id != _lidPorcentajeInfo)
                    CalcResultRow(
                      titulo: _uiLabelForId(item, t),
                      valorCrudo: _getLiquidosIvDisplay(item),
                      destacado: item.id == _lidResultado,
                      onTap: () => _abrirDetalle(item, 'Liquidos IV'),
                    ),
              ],
            ),
            CalcSeccionCard(
              titulo: t.specialCalcSectionSodium,
              icono: Icons.science_outlined,
              children: [
                for (final item in sodioMedicamentos.skip(1))
                  CalcResultRow(
                    titulo: _uiLabelForId(item, t),
                    valorCrudo: _getSodioDisplay(item),
                    onTap: () => _abrirDetalle(item, 'Sodio'),
                  ),
              ],
            ),
            CalcSeccionCard(
              titulo: t.specialCalcSectionHco3,
              icono: Icons.biotech_outlined,
              children: [
                for (final item in hco3Medicamentos.skip(1))
                  CalcResultRow(
                    titulo: _uiLabelForId(item, t),
                    valorCrudo: _getHco3Display(item),
                    onTap: () => _abrirDetalle(item, 'HCO3'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
