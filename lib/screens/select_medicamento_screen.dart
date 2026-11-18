// lib/screens/select_medicamento_screen.dart
import 'package:flutter/material.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/data/medicamento_data.dart';
import 'package:mi_app/screens/medicamento_detail_screen.dart';
import 'package:mi_app/screens/printable_patient_data_screen.dart';
import 'package:mi_app/models/medicamento_calculado.dart';
import 'package:mi_app/utils/dosis_calculator.dart';
import 'package:mi_app/screens/calculos_especiales_jovenes_screen.dart';
import 'package:mi_app/screens/edad_selection_screen.dart';

import 'package:mi_app/screens/heart_rate_screen_jovenes.dart';
import 'package:mi_app/screens/respiratory_rate_screen_jovenes.dart';
import 'package:mi_app/screens/blood_pressure_screen_jovenes.dart';
import 'package:mi_app/screens/temperature_screen_jovenes.dart';
import 'package:mi_app/screens/oxygen_saturation_screen_jovenes.dart';
import 'package:mi_app/screens/presion_arterial_mujeres_screen_jovenes.dart';
import 'package:mi_app/screens/presion_arterial_hombres_screen_jovenes.dart';

import '../l10n/app_localizations.dart';
import '../widgets/vitales_menu.dart';
import '../i18n/med_i18n.dart';
import '../data/menu_categorias.dart';
import '../utils/favoritos_store.dart';
import '../widgets/menu_pestanas.dart';

class SelectMedicamentoScreen extends StatefulWidget {
  final Paciente paciente;
  final bool esPesoEstimado;

  const SelectMedicamentoScreen({
    super.key,
    required this.paciente,
    this.esPesoEstimado = false,
  });

  @override
  State<SelectMedicamentoScreen> createState() =>
      _SelectMedicamentoScreenState();
}

enum _VitalOption {
  heartRate,
  respRate,
  bloodPressure,
  temperature,
  oxygenSat,
  bpWomen,
  bpMen,
}

class _SelectMedicamentoScreenState extends State<SelectMedicamentoScreen> {
  // Colores base de tu app
  static const Color _primaryBlueDark = Color.fromARGB(255, 14, 113, 194);
  static const Color _highlightGreen = Color.fromARGB(255, 83, 232, 103);

  /// Verde oscuro para las dosis: legible sobre blanco (contraste ~6:1).
  static const Color _doseGreen = Color(0xFF1B7F3B);

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  /// Pestaña del menú elegida; null = todas.
  MenuPestana? _pestana;

  bool _onlyFavorites = false;

  final FavoritosStore _favoritos = FavoritosStore.de('anios');

  static const double _buttonBarHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _favoritos.claves.addListener(_onFavoritosChanged);
    _favoritos.cargar();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase().trim();
      });
    });
  }

  void _onFavoritosChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _favoritos.claves.removeListener(_onFavoritosChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openVitalOption(_VitalOption opt) async {
    Widget? screen;

    switch (opt) {
      case _VitalOption.heartRate:
        screen = HeartRateScreenJ(paciente: widget.paciente);
        break;
      case _VitalOption.respRate:
        screen = RespiratoryRateScreenJ(paciente: widget.paciente);
        break;
      case _VitalOption.bloodPressure:
        screen = BloodPressureScreenJ(paciente: widget.paciente);
        break;
      case _VitalOption.temperature:
        screen = const TemperatureScreenJ();
        break;
      case _VitalOption.oxygenSat:
        screen = const OxygenSaturationScreenJ();
        break;
      case _VitalOption.bpWomen:
        screen = PresionArterialMujeresScreenJ(paciente: widget.paciente);
        break;
      case _VitalOption.bpMen:
        screen = PresionArterialHombresScreenJ(paciente: widget.paciente);
        break;
    }

    if (screen == null) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => screen!));
  }

  // ============================
  // ✅ MODALES CENTRADOS (SING V / PAM)
  // ============================
  // Colores de los íconos de signos vitales.
  static const Color _cFc = Color(0xFFD64545);
  static const Color _cFr = Color(0xFF2E8B57);
  static const Color _cPa = Color(0xFF0E71C2);
  static const Color _cTemp = Color(0xFFE08A00);
  static const Color _cO2 = Color(0xFF00897B);

  void _showSignosVitalesOptions(AppLocalizations t) {
    mostrarMenuVitales(
      context,
      titulo: t.vsTitle,
      subtitulo: t.vsSubtitle,
      icono: Icons.monitor_heart_outlined,
      opciones: [
        VitalOpcion(
          icono: Icons.favorite,
          color: _cFc,
          titulo: t.vitalHeartRate,
          subtitulo: t.vsHrSub,
          abrir: () => _openVitalOption(_VitalOption.heartRate),
        ),
        VitalOpcion(
          icono: Icons.air,
          color: _cFr,
          titulo: t.vitalRespRate,
          subtitulo: t.vsRrSub,
          abrir: () => _openVitalOption(_VitalOption.respRate),
        ),
        VitalOpcion(
          icono: Icons.speed,
          color: _cPa,
          titulo: t.vitalBloodPressure,
          subtitulo: t.vsBpSub,
          abrir: () => _openVitalOption(_VitalOption.bloodPressure),
        ),
        VitalOpcion(
          icono: Icons.thermostat,
          color: _cTemp,
          titulo: t.vitalTemperature,
          subtitulo: t.vsTempSub,
          abrir: () => _openVitalOption(_VitalOption.temperature),
        ),
        VitalOpcion(
          icono: Icons.bubble_chart_outlined,
          color: _cO2,
          titulo: t.vitalOxygenSat,
          subtitulo: t.vsO2Sub,
          abrir: () => _openVitalOption(_VitalOption.oxygenSat),
        ),
      ],
    );
  }

  void _showPAMOptions(AppLocalizations t) {
    mostrarMenuVitales(
      context,
      titulo: t.pamTitle,
      subtitulo: t.pamSubtitle,
      icono: Icons.favorite_outline,
      opciones: [
        VitalOpcion(
          icono: Icons.female,
          color: const Color(0xFFC2185B),
          titulo: t.pamWomen,
          subtitulo: t.pamTableSub,
          abrir: () => _openVitalOption(_VitalOption.bpWomen),
        ),
        VitalOpcion(
          icono: Icons.male,
          color: const Color(0xFF1565C0),
          titulo: t.pamMen,
          subtitulo: t.pamTableSub,
          abrir: () => _openVitalOption(_VitalOption.bpMen),
        ),
      ],
    );
  }

  // ============================
  // Data / agrupación / búsqueda
  // ============================
  List<Medicamento> _getFilteredMedicamentos() {
    return allMedicamentos
        .where(
          (med) =>
              med.categoria != 'REPOSICION DE SODIO (Na <130mEq/L)' &&
              med.categoria != 'Reposición de HCO3',
        )
        .toList();
  }

  /// ✅ Búsqueda en EN/ES usando texto UI (traducción)
  List<Medicamento> _getFilteredMedicamentosForSearch(AppLocalizations t) {
    if (_searchText.isEmpty) return [];

    final q = _searchText.trim().toLowerCase();

    return _getFilteredMedicamentos().where((med) {
      final nombreUi = MedI18n.name(med, t).toLowerCase();
      final categoriaUi = MedI18n.category(med.categoria, t).toLowerCase();
      final sub = (med.subcategoria ?? '').toLowerCase();

      return nombreUi.contains(q) || categoriaUi.contains(q) || sub.contains(q);
    }).toList();
  }

  bool _passesFavoriteFilter(Medicamento med) =>
      !_onlyFavorites || _favoritos.esFavorito(med);

  // ============================
  // Cálculo de dosis display
  // ============================
  String _formatDosis(double dosis) {
    final roundedDosis = double.parse(dosis.toStringAsFixed(2));
    if (roundedDosis == roundedDosis.toInt()) {
      return roundedDosis.toInt().toString();
    }
    return roundedDosis.toString();
  }

  String _getDosisDisplay(Medicamento medicamento) {
    final Map<String, dynamic> calculatedDoses = DosisCalculator.calculateDosis(
      widget.paciente,
      medicamento,
    );

    if (calculatedDoses.containsKey('display_string')) {
      return (calculatedDoses['display_string'] as String).trim();
    }

    final double dosisMl = calculatedDoses['ml'] ?? 0.0;
    final double dosisMg = calculatedDoses['mg'] ?? 0.0;
    final double dosisJulios = calculatedDoses['julios'] ?? 0.0;

    final partes = <String>[
      if (dosisMl > 0.005) '${_formatDosis(dosisMl)} ml',
      if (dosisMg > 0.005) '${_formatDosis(dosisMg)} mg',
      if (dosisJulios > 0.005) '${_formatDosis(dosisJulios)} J',
    ];
    return partes.isEmpty ? 'N/A' : partes.join(' · ');
  }

  // ============================
  // UI: Tile del medicamento
  // ============================
  Widget _buildMedicamentoListTile(
    Medicamento medicamento,
    AppLocalizations t,
  ) {
    final String dosisDisplay = _getDosisDisplay(medicamento);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE3EAF2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: _primaryBlueDark.withAlpha((0.05 * 255).round()),
          splashColor: _primaryBlueDark.withAlpha((0.15 * 255).round()),
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicamentoDetailScreen(
                  medicamento: medicamento,
                  paciente: widget.paciente,
                  esPesoEstimado: widget.esPesoEstimado,
                ),
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
            leading: FavoritoButton(
              esFavorito: _favoritos.esFavorito(medicamento),
              onPressed: () => _favoritos.alternar(medicamento),
            ),
            minLeadingWidth: 0,
            horizontalTitleGap: 4,
            title: Text(
              MedI18n.name(medicamento, t),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF14212C),
              ),
            ),
            // La dosis va debajo del nombre: así ninguno de los dos se corta.
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                dosisDisplay,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _doseGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 26,
              color: _primaryBlueDark,
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // UI: Header paciente
  // ============================
  Widget _patientHeader(AppLocalizations t) {
    final peso = widget.paciente.pesoKg;
    final edad = widget.paciente.edadAnios;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person, color: _primaryBlueDark),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    t.patientHeaderSummaryYears(
                      peso.toStringAsFixed(1),
                      edad > 0 ? edad.toString() : t.commonNA,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Chip(
                    label: Text(
                      widget.esPesoEstimado
                          ? t.medsChipEstimated
                          : t.medsChipRealWeight,
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: widget.esPesoEstimado
                        ? const Color(0xFFFFF7E6)
                        : const Color(0xFFE9F7EF),
                    side: BorderSide(
                      color: widget.esPesoEstimado
                          ? const Color(0xFFFFE0B2)
                          : const Color(0xFFB7E4C7),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EdadSelectionScreen(),
                  ),
                );
              },
              child: Text(t.medsBtnChange),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // UI: Buscador
  // ============================
  PreferredSizeWidget _buildSearchBar(AppLocalizations t) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(54.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: t.medsSearchHint,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color.fromARGB(255, 254, 254, 254),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 143, 143, 143),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: _highlightGreen, width: 3.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuPestanas() {
    return MenuPestanasBar(
      seleccion: _pestana,
      soloFavoritos: _onlyFavorites,
      onSeleccion: (p) => setState(() => _pestana = p),
      onSoloFavoritos: (v) => setState(() => _onlyFavorites = v),
    );
  }

  // Tarjeta cálculos especiales
  Widget _specialCalculationsCard(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CalculosEspecialesJovenesScreen(
                paciente: widget.paciente,
                esPesoEstimado: widget.esPesoEstimado,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _primaryBlueDark.withAlpha((0.25 * 255).round()),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calculate, color: _primaryBlueDark),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.medsSpecialCalculations,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _primaryBlueDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _primaryBlueDark),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // Imprimir (sin cambios de lógica)
  // ============================
  void _onPrintAll() {
    final List<MedicamentoCalculado> allCalculatedMeds = [];

    for (var med in _getFilteredMedicamentos()) {
      final Map<String, dynamic> calculatedDoses =
          DosisCalculator.calculateDosis(widget.paciente, med);

      if (calculatedDoses.containsKey('display_string')) {
        allCalculatedMeds.add(
          MedicamentoCalculado(
            medicamentoOriginal: med,
            dosisMlDisplay: calculatedDoses['display_string'] as String,
            dosisMgDisplay: 'N/A',
            dosisJuliosDisplay: 'N/A',
          ),
        );
      } else {
        final double dosisMl = (calculatedDoses['ml'] as double?) ?? 0.0;
        final double dosisMg = (calculatedDoses['mg'] as double?) ?? 0.0;
        final double dosisJulios =
            (calculatedDoses['julios'] as double?) ?? 0.0;

        allCalculatedMeds.add(
          MedicamentoCalculado(
            medicamentoOriginal: med,
            dosisMlDisplay: dosisMl > 0.005
                ? '${_formatDosis(dosisMl)} ml'
                : 'N/A',
            dosisMgDisplay: dosisMg > 0.005
                ? '${_formatDosis(dosisMg)} mg'
                : 'N/A',
            dosisJuliosDisplay: dosisJulios > 0.005
                ? '${_formatDosis(dosisJulios)} J'
                : 'N/A',
          ),
        );
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrintablePatientDataScreen(
          paciente: widget.paciente,
          esPesoEstimado: widget.esPesoEstimado,
          esLactante: false,
          medicamentosCalculados: allCalculatedMeds,
        ),
      ),
    );
  }

  // ============================
  // BUILD
  // ============================
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final List<Medicamento> searchResults = _getFilteredMedicamentosForSearch(
      t,
    );
    final List<Widget> displayedListItems = [];

    if (_searchText.isNotEmpty) {
      // La búsqueda recorre todas las pestañas.
      for (var medicamento in searchResults) {
        displayedListItems.add(_buildMedicamentoListTile(medicamento, t));
      }
    } else {
      displayedListItems.add(_patientHeader(t));
      displayedListItems.add(_menuPestanas());

      // Sodio, HCO3 y líquidos IV están en "Cálculos especiales" → Electrolitos.
      if (!_onlyFavorites &&
          (_pestana == null || _pestana == MenuPestana.electrolitos)) {
        displayedListItems.add(_specialCalculationsCard(t));
      }

      final agrupado = agruparPorPestana(
        _getFilteredMedicamentos().where(_passesFavoriteFilter),
        nombreCategoria: (c) => MedI18n.category(c, t),
        nombreMed: (m) => MedI18n.name(m, t),
      );

      var hayMedicamentos = false;
      agrupado.forEach((pestana, categorias) {
        if (_pestana != null && _pestana != pestana) return;
        hayMedicamentos = true;

        if (_pestana == null) {
          displayedListItems.add(
            PestanaHeader(
              key: ValueKey('tab-${pestana.name}'),
              pestana: pestana,
            ),
          );
        }

        categorias.forEach((categoria, medicamentos) {
          displayedListItems.add(
            CategoriaHeader(
              key: ValueKey(categoria),
              texto: MedI18n.category(categoria, t),
              pestana: pestana,
            ),
          );
          for (var medicamento in medicamentos) {
            displayedListItems.add(_buildMedicamentoListTile(medicamento, t));
          }
        });
      });

      if (_onlyFavorites && !hayMedicamentos) {
        displayedListItems.add(const FavoritosVacio());
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.medsTitleYears),
          bottom: _buildSearchBar(t),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _onPrintAll,
              tooltip: t.medsPrintTooltip,
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: _buttonBarHeight + 20),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) =>
                          displayedListItems[index],
                      childCount: displayedListItems.length,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Container(
                    height: _buttonBarHeight,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _BottomActionButton(
                            label: t.medsBottomSINGV,
                            icon: Icons.monitor_heart_outlined,
                            background: _primaryBlueDark,
                            onTap: () => _showSignosVitalesOptions(t),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BottomActionButton(
                            label: t.medsBottomPAM,
                            icon: Icons.favorite_outline,
                            background: _primaryBlueDark,
                            onTap: () => _showPAMOptions(t),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// ✅ Botón inferior más pro
/// ===============================
class _BottomActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  const _BottomActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
