// lib/screens/medicamentos_list_meses_screen.dart
import 'package:flutter/material.dart';

import 'package:mi_app/data/medicamento_data_meses.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/screens/medicamento_detail_meses_screen.dart';
import 'package:mi_app/screens/printable_patient_data_screen.dart';
import 'package:mi_app/utils/dosis_calculator_meses.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/models/medicamento_calculado.dart';
import 'package:mi_app/screens/calculos_especiales_screen.dart';

// ✅ Para botón Cambiar
import 'package:mi_app/screens/edad_selection_screen.dart';

// Pantallas
import 'package:mi_app/screens/heart_rate_screen.dart';
import 'package:mi_app/screens/respiratory_rate_screen.dart';
import 'package:mi_app/screens/blood_pressure_screen.dart';
import 'package:mi_app/screens/temperature_screen.dart';
import 'package:mi_app/screens/oxygen_saturation_screen.dart';
import 'package:mi_app/screens/presion_arterial_mujeres_screen.dart';
import 'package:mi_app/screens/presion_arterial_hombres_screen.dart';

import '../l10n/app_localizations.dart';
import '../widgets/vitales_menu.dart';
import '../i18n/med_i18n.dart';
import '../utils/calc_messages.dart';
import '../data/menu_categorias.dart';
import '../utils/favoritos_store.dart';
import '../widgets/menu_pestanas.dart';

class MedicamentosListMesesScreen extends StatefulWidget {
  final Paciente paciente;

  /// ✅ Nuevo: para mostrar chip “Estimado ⚠️” o “Peso real ✅”
  final bool esPesoEstimado;

  const MedicamentosListMesesScreen({
    super.key,
    required this.paciente,
    this.esPesoEstimado = false,
  });

  @override
  State<MedicamentosListMesesScreen> createState() =>
      _MedicamentosListMesesScreenState();
}

class _MedicamentosListMesesScreenState
    extends State<MedicamentosListMesesScreen> {
  // Colores base
  static const Color _primaryBlueDark = Color.fromARGB(255, 14, 113, 194);
  static const Color _highlightGreen = Color.fromARGB(255, 83, 232, 103);

  /// Verde oscuro para las dosis: legible sobre blanco (contraste ~6:1).
  static const Color _doseGreen = Color(0xFF1B7F3B);

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  /// Pestaña del menú elegida; null = todas.
  MenuPestana? _pestana;

  bool _onlyFavorites = false;

  final FavoritosStore _favoritos = FavoritosStore.de('meses');

  // Barra inferior fija
  static const double _buttonBarHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _favoritos.claves.addListener(_onFavoritosChanged);
    _favoritos.cargar();

    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.toLowerCase().trim());
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

  // ============================
  // ✅ VITALES: ahora por KEY (no por texto UI)
  // ============================

  Future<void> _openVitalOptionKeyAndWait(String key) async {
    Widget? screen;

    if (key == 'HR') {
      screen = HeartRateScreen(paciente: widget.paciente);
    } else if (key == 'RR') {
      screen = RespiratoryRateScreen(paciente: widget.paciente);
    } else if (key == 'BP') {
      screen = BloodPressureScreen(paciente: widget.paciente);
    } else if (key == 'TEMP') {
      screen = const TemperatureScreen();
    } else if (key == 'O2') {
      screen = const OxygenSaturationScreen();
    } else if (key == 'BP_W') {
      screen = PresionArterialMujeresScreen(paciente: widget.paciente);
    } else if (key == 'BP_M') {
      screen = PresionArterialHombresScreen(paciente: widget.paciente);
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
          abrir: () => _openVitalOptionKeyAndWait('HR'),
        ),
        VitalOpcion(
          icono: Icons.air,
          color: _cFr,
          titulo: t.vitalRespRate,
          subtitulo: t.vsRrSub,
          abrir: () => _openVitalOptionKeyAndWait('RR'),
        ),
        VitalOpcion(
          icono: Icons.speed,
          color: _cPa,
          titulo: t.vitalBloodPressure,
          subtitulo: t.vsBpSub,
          abrir: () => _openVitalOptionKeyAndWait('BP'),
        ),
        VitalOpcion(
          icono: Icons.thermostat,
          color: _cTemp,
          titulo: t.vitalTemperature,
          subtitulo: t.vsTempSub,
          abrir: () => _openVitalOptionKeyAndWait('TEMP'),
        ),
        VitalOpcion(
          icono: Icons.bubble_chart_outlined,
          color: _cO2,
          titulo: t.vitalOxygenSat,
          subtitulo: t.vsO2Sub,
          abrir: () => _openVitalOptionKeyAndWait('O2'),
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
          abrir: () => _openVitalOptionKeyAndWait('BP_W'),
        ),
        VitalOpcion(
          icono: Icons.male,
          color: const Color(0xFF1565C0),
          titulo: t.pamMen,
          subtitulo: t.pamTableSub,
          abrir: () => _openVitalOptionKeyAndWait('BP_M'),
        ),
      ],
    );
  }

  // ============================
  // DATA
  // ============================

  // Estas categorías se calculan en "Cálculos especiales".
  static final Set<String> _categoriasExcluidas = {
    normalizarCategoria('Líquids IV'),
    normalizarCategoria('Reposición de HCO3'),
    normalizarCategoria('Reposición de Sodio'),
  };

  bool _isExcludedCategoria(String categoria) =>
      _categoriasExcluidas.contains(normalizarCategoria(categoria));

  List<Medicamento> _getFilteredMedicamentos() {
    return medicamentosMeses
        .where((m) => !_isExcludedCategoria(m.categoria))
        .toList();
  }

  List<Medicamento> _getSearchResults(AppLocalizations t) {
    if (_searchText.isEmpty) return [];

    return _getFilteredMedicamentos().where((m) {
      final nombre = MedI18n.name(m, t).toLowerCase();
      final categoria = MedI18n.category(m.categoria, t).toLowerCase();
      final dosisActual = MedI18n.currentDose(m, t).toLowerCase();
      final rango = MedI18n.rangeDose(m, t).toLowerCase();
      final obs = MedI18n.notes(m, t).toLowerCase();
      final sub = (m.subcategoria ?? '').toLowerCase();

      return nombre.contains(_searchText) ||
          categoria.contains(_searchText) ||
          sub.contains(_searchText) ||
          dosisActual.contains(_searchText) ||
          rango.contains(_searchText) ||
          obs.contains(_searchText);
    }).toList();
  }

  bool _passesFavoriteFilter(Medicamento med) =>
      !_onlyFavorites || _favoritos.esFavorito(med);

  // ============================
  // Dosis display (Meses)
  // ============================
  String _getDosisDisplay(Medicamento medicamento) {
    final Map<String, dynamic> calculated = DosisCalculatorMeses.calculateDosis(
      widget.paciente,
      medicamento,
    );

    if (calculated.containsKey('display_string')) {
      return CalcMsg.localize(
        (calculated['display_string'] as String).trim(),
        AppLocalizations.of(context),
      );
    }

    final double dosisMl = (calculated['ml'] as double?) ?? 0.0;
    final double dosisMg = (calculated['mg'] as double?) ?? 0.0;
    final double dosisJ = (calculated['julios'] as double?) ?? 0.0;

    final List<String> doses = [];
    if (dosisMl > 0.005)
      doses.add('${DosisCalculatorMeses.formatDosis(dosisMl)} ml');
    if (dosisMg > 0.005)
      doses.add('${DosisCalculatorMeses.formatDosis(dosisMg)} mg');
    if (dosisJ > 0.005)
      doses.add('${DosisCalculatorMeses.formatDosis(dosisJ)} J');

    return doses.isEmpty ? 'N/A' : doses.join(' · ');
  }

  // ============================
  // Tile medicamento
  // ============================
  Widget _buildMedicamentoListTile(
    Medicamento medicamento,
    AppLocalizations t,
  ) {
    final dosisDisplay = _getDosisDisplay(medicamento);

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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MedicamentoDetailMesesScreen(
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
  // Header paciente
  // ============================
  Widget _patientHeader(AppLocalizations t) {
    final peso = widget.paciente.pesoKg;
    final meses = widget.paciente.edadMeses;

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
                    '${peso.toStringAsFixed(1)} kg · ${meses > 0 ? '$meses ${t.patientHeaderMonthsUnit}' : t.commonNA}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Chip(
                    label: Text(
                      widget.esPesoEstimado
                          ? t.chipEstimated
                          : t.chipRealWeight,
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
              child: Text(t.btnChange),
            ),
          ],
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

  // ============================
  // Cálculos especiales
  // ============================
  Widget _specialCalculationsCard(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CalculosEspecialesScreen(
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
                  t.specialCalculations,
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
  // Search bar
  // ============================
  PreferredSizeWidget _buildSearchBar(AppLocalizations t) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(54.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: t.searchMedicationHint,
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

  // ============================
  // Print
  // ============================
  List<MedicamentoCalculado> _calcularTodasLasDosis() {
    return medicamentosMeses.map((medicamento) {
      final Map<String, dynamic> calculated =
          DosisCalculatorMeses.calculateDosis(widget.paciente, medicamento);

      String ml = 'N/A', mg = 'N/A', j = 'N/A';

      if (calculated.containsKey('display_string')) {
        ml = CalcMsg.localize(
          (calculated['display_string'] as String).trim(),
          AppLocalizations.of(context),
        );
      } else {
        final double dosisMl = (calculated['ml'] as double?) ?? 0.0;
        final double dosisMg = (calculated['mg'] as double?) ?? 0.0;
        final double dosisJ = (calculated['julios'] as double?) ?? 0.0;

        if (dosisMl > 0.005)
          ml = '${DosisCalculatorMeses.formatDosis(dosisMl)} ml';
        if (dosisMg > 0.005)
          mg = '${DosisCalculatorMeses.formatDosis(dosisMg)} mg';
        if (dosisJ > 0.005) j = '${DosisCalculatorMeses.formatDosis(dosisJ)} J';
      }

      return MedicamentoCalculado(
        medicamentoOriginal: medicamento,
        dosisMlDisplay: ml,
        dosisMgDisplay: mg,
        dosisJuliosDisplay: j,
      );
    }).toList();
  }

  void _onPrintAll() {
    final meds = _calcularTodasLasDosis();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrintablePatientDataScreen(
          paciente: widget.paciente,
          esPesoEstimado: widget.esPesoEstimado,
          esLactante: true,
          medicamentosCalculados: meds,
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

    final searchResults = _getSearchResults(t);
    final List<Widget> items = [];

    if (_searchText.isNotEmpty) {
      // La búsqueda recorre todas las pestañas.
      for (final med in searchResults) {
        items.add(_buildMedicamentoListTile(med, t));
      }
    } else {
      items.add(_patientHeader(t));
      items.add(_menuPestanas());

      // "Cálculos especiales" = sodio y HCO3 (Electrolitos) + líquidos IV (Shock).
      if (!_onlyFavorites &&
          (_pestana == null ||
              _pestana == MenuPestana.electrolitos ||
              _pestana == MenuPestana.shock)) {
        items.add(_specialCalculationsCard(t));
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
          items.add(
            PestanaHeader(
              key: ValueKey('tab-${pestana.name}'),
              pestana: pestana,
            ),
          );
        }

        categorias.forEach((categoria, medicamentos) {
          items.add(
            CategoriaHeader(
              key: ValueKey(categoria),
              texto: MedI18n.category(categoria, t),
              pestana: pestana,
            ),
          );
          for (final med in medicamentos) {
            items.add(_buildMedicamentoListTile(med, t));
          }
        });
      });

      if (_onlyFavorites && !hayMedicamentos) {
        items.add(const FavoritosVacio());
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.medsMonthsAppBarTitle),
          bottom: _buildSearchBar(t),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _onPrintAll,
              tooltip: t.printFullReport,
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
                      (context, index) => items[index],
                      childCount: items.length,
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
                            label: t.bottomVitals, // ✅ i18n
                            icon: Icons.monitor_heart_outlined,
                            background: _primaryBlueDark,
                            onTap: () => _showSignosVitalesOptions(t),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BottomActionButton(
                            label: t.bottomPam, // ✅ i18n
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

// ===============================
// Helpers
// ===============================

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
