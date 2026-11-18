import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/models/medicamento.dart';
import 'package:mi_app/models/paciente.dart';
import 'package:mi_app/utils/calc_messages.dart';
import 'package:mi_app/utils/dosis_calculator.dart';
import 'package:mi_app/utils/dosis_calculator_jovenes.dart';
import 'package:mi_app/utils/dosis_calculator_meses.dart';

Map<String, dynamic> calc(double peso, String nombre, [String categoria = '']) {
  return DosisCalculator.calculateDosis(
    Paciente(pesoKg: peso, edadAnios: 5, edadMeses: 0),
    Medicamento(id: '', nombre: nombre, categoria: categoria),
  );
}

Map<String, dynamic> calcMeses(double peso, String nombre) {
  return DosisCalculatorMeses.calculateDosis(
    Paciente(pesoKg: peso, edadAnios: 0, edadMeses: 6),
    Medicamento(id: '', nombre: nombre, categoria: ''),
  );
}

void main() {
  group('1. Adenosina (3 mg/ml): ml = mg / 3', () {
    test('primera, 20 kg → 2 mg, 0.67 ml', () {
      final r = calc(20, 'Adenosina primera');
      expect(r['mg'], 2.0);
      expect(r['ml'], 0.67);
    });
    test('primera, tope 6 mg = 2 ml', () {
      final r = calc(80, 'Adenosina primera');
      expect(r['mg'], 6.0);
      expect(r['ml'], 2.0);
    });
    test('segunda, 30 kg → 6 mg, 2 ml', () {
      final r = calc(30, 'Adenosina segunda');
      expect(r['mg'], 6.0);
      expect(r['ml'], 2.0);
    });
    test('tercera, tope 12 mg = 4 ml', () {
      final r = calc(60, 'Adenosina tercera');
      expect(r['mg'], 12.0);
      expect(r['ml'], 4.0);
    });
    test('lactante 4 kg no redondea a 0', () {
      final r = calc(4, 'Adenosina primera');
      expect(r['mg'], 0.4);
      expect(r['ml'], 0.13);
    });
    test('meses: 6 kg → 0.2 ml (antes 0.6 ml)', () {
      expect(calcMeses(6, 'Adenosina primera')['ml'], 0.2);
      expect(calcMeses(6, 'Adenosina segunda')['ml'], 0.4);
    });
  });

  group('2. Sin ml falsos iguales a mg', () {
    const soloMg = {
      'Valproato IV': 400.0, // 20 mg/kg
      'Fenitoína IV.': 400.0,
      'Levetirazetam': 600.0, // 30 mg/kg
      'Tiopental': 60.0,
      'Fenobarbital.': 400.0,
      'Paracetamol': 300.0,
      'Midazolam IV.': 3.0,
      'Metamizol IV.': 120.0,
      'Diazepam IV.': 2.0,
      'Clonazepam VO': 0.2,
    };
    soloMg.forEach((nombre, mg) {
      test('$nombre (20 kg) → $mg mg, 0 ml', () {
        final r = calc(20, nombre);
        expect(r['mg'], mg);
        expect(r['ml'], 0.0);
      });
    });
    test('topes en mg se mantienen', () {
      expect(calc(80, 'Valproato IV')['mg'], 1000.0);
      expect(calc(200, 'Levetirazetam')['mg'], 4500.0);
      expect(calc(200, 'Tiopental')['mg'], 500.0);
    });
    test('Sol hipertónica 3% solo en ml', () {
      final r = calc(20, 'Sol hipertónica 3%');
      expect(r['ml'], 60.0);
      expect(r['mg'], 0.0);
    });
  });

  group('3. Sin HCO3 fijo en 7', () {
    test('las ramas fijas ya no devuelven un valor calculado', () {
      expect(calc(20, 'HCO3 del paciente')['ml'], 0.0);
      expect(calc(20, 'Déficit de HCO3')['ml'], 0.0);
      expect(calc(20, 'Velocidad de Infusión.')['ml'], 0.0);
    });
  });

  group('4. Redondeo de dosis pequeñas', () {
    test('Morfina. 4 kg → 0.4 mg / 0.4 ml (antes 0)', () {
      final r = calc(4, 'Morfina.');
      expect(r['mg'], 0.4);
      expect(r['ml'], 0.4);
    });
    test('Ketamina 4 kg → 0.4 ml (antes 0)', () {
      expect(calc(4, 'Ketamina')['ml'], 0.4);
    });
    test('Rocuronio IV 3 kg → 1.5 mg (antes 2)', () {
      expect(calc(3, 'Rocuronio IV')['mg'], 1.5);
    });
    test('Naloxona 4 kg → 0.04 mg, 0.1 ml', () {
      final r = calc(4, 'Naloxona');
      expect(r['mg'], 0.04);
      expect(r['ml'], 0.1);
    });
    test('Adrenalina IM 4 kg → 0.04 ml (antes 0)', () {
      expect(calc(4, 'Adrenalina IM', 'Anafilaxia')['ml'], 0.04);
    });
    test('Insulina simple 3 kg → 0.3 UI', () {
      expect(
        calc(3, 'Insulina simple', 'Endocrino / Renal')['display_string'],
        '0.3 UI',
      );
    });
    test('meses: Adrenalina IM 3 kg → 0.03 ml', () {
      expect(calcMeses(3, 'Adrenalina IM')['ml'], 0.03);
    });
  });

  group('5. Topes coherentes entre ml y mg', () {
    test('Adrenalina ET 20 kg → 1 mg = 10 ml (antes 20 ml)', () {
      final r = calc(20, 'Adrenalina ET', 'Paro cardiaco');
      expect(r['mg'], 1.0);
      expect(r['ml'], 10.0);
    });
    test('Adrenalina ET 5 kg → 0.5 mg = 5 ml', () {
      final r = calc(5, 'Adrenalina ET', 'Paro cardiaco');
      expect(r['mg'], 0.5);
      expect(r['ml'], 5.0);
    });
    test('Sulfato de magnesio 60 kg → 2000 mg = 10 ml', () {
      final r = calc(60, 'Sulfato de magnesio');
      expect(r['mg'], 2000.0);
      expect(r['ml'], 10.0);
    });
    test('Midazolam IV 70 kg → 15 mg = 3 ml', () {
      final r = calc(70, 'Midazolam IV');
      expect(r['mg'], 15.0);
      expect(r['ml'], 3.0);
    });
    test('Morfina. 150 kg → 10 mg = 10 ml', () {
      final r = calc(150, 'Morfina.');
      expect(r['mg'], 10.0);
      expect(r['ml'], 10.0);
    });
  });

  group('6. Holliday-Segar', () {
    final casos = <double, double>{
      5.0: 500.0,
      10.0: 1000.0,
      15.0: 1250.0,
      20.0: 1500.0,
      20.5: 1510.0, // antes 1535
      30.0: 1700.0,
    };
    casos.forEach((peso, ml) {
      test('$peso kg → $ml ml/día', () {
        expect(DosisCalculator.hollidaySegar(peso), closeTo(ml, 0.001));
        expect(calc(peso, 'Solución mixta mantenimiento')['ml'], ml);
      });
    });
    test('jóvenes coincide con la misma fórmula', () {
      final r = DosisCalculatorJovenes.calculateLiquidosIvDosis(20.5, 100);
      expect(r['solucion_mixta'], '1510.00 cc');
    });
  });

  group('7. Bradiarritmias (0,1 mg/ml)', () {
    test('Adrenalina IV 10 kg → 0.1 mg = 1 ml', () {
      final r = calc(10, 'Adrenalina IV', 'Bradiarritmias');
      expect(r['mg'], 0.1);
      expect(r['ml'], 1.0);
    });
    test('Adrenalina IV tope 1 mg = 10 ml', () {
      final r = calc(150, 'Adrenalina IV', 'Bradiarritmias');
      expect(r['mg'], 1.0);
      expect(r['ml'], 10.0);
    });
    test('Atropina 10 kg → 0.2 mg = 2 ml', () {
      final r = calc(10, 'Atropina');
      expect(r['mg'], 0.2);
      expect(r['ml'], 2.0);
    });
    test('Atropina tope 1 mg = 10 ml', () {
      final r = calc(80, 'Atropina');
      expect(r['mg'], 1.0);
      expect(r['ml'], 10.0);
    });
    test('coincide con la calculadora de meses', () {
      expect(calcMeses(8, 'Atropina')['ml'], calc(8, 'Atropina')['ml']);
    });
  });

  group('8. Sin déficits negativos', () {
    test('jóvenes: Na ≥ 130 → sin déficit', () {
      final r = DosisCalculatorJovenes.calculateSodioDosis(20, 135);
      expect(r['deficit_display'], CalcMsg.noSodiumDeficit);
      expect(r['con_sf_display'], 'N/A');
    });
    test('jóvenes: Na 120 sigue calculando', () {
      final r = DosisCalculatorJovenes.calculateSodioDosis(20, 120);
      expect(r['deficit_display'], '30.0 ml');
    });
    test('jóvenes: HCO3 ≥ 15 → sin déficit', () {
      final r = DosisCalculatorJovenes.calculateHco3Dosis(20, 18);
      expect(r['deficit_display'], CalcMsg.noHco3Deficit);
    });
    test('jóvenes: valores 0 piden dato', () {
      expect(
        DosisCalculatorJovenes.calculateSodioDosis(20, 0)['deficit_display'],
        CalcMsg.needSodium,
      );
      expect(
        DosisCalculatorJovenes.calculateHco3Dosis(20, 0)['deficit_display'],
        CalcMsg.needHco3,
      );
      expect(
        DosisCalculatorJovenes.calculateLiquidosIvDosis(0, 100)['resultado'],
        'N/A',
      );
    });
    final lactante = Paciente(pesoKg: 8, edadAnios: 0, edadMeses: 6);
    test('meses: Na 128 → déficit positivo hacia 130', () {
      final r = DosisCalculatorMeses.calculateSodioDosis(lactante, 128);
      expect(r['deficit_display'], '2.4 mL'); // (130-128)·8·0,6/4
    });
    test('meses: Na ≥ 130 y HCO3 ≥ 15 → sin déficit', () {
      expect(
        DosisCalculatorMeses.calculateSodioDosis(
          lactante,
          132,
        )['deficit_display'],
        CalcMsg.noSodiumDeficit,
      );
      expect(
        DosisCalculatorMeses.calculateHco3Dosis(
          lactante,
          20,
        )['deficit_display'],
        CalcMsg.noHco3Deficit,
      );
    });
  });

  group('Comparación con la tabla Excel "para APP"', () {
    test('sodio meses = Excel (Na 120, 22,6 kg)', () {
      final p = Paciente(pesoKg: 22.6, edadAnios: 0, edadMeses: 6);
      final r = DosisCalculatorMeses.calculateSodioDosis(p, 120);
      expect(r['deficit_display'], '33.9 mL');
      expect(r['volumen_display'], '237.3 mL');
      expect(r['velocidad_display'], '79 mL/h');
      expect(r['con_sf_display'], '881 mL');
    });
    test('sodio jóvenes = Excel (Na 120, 22,6 kg)', () {
      final r = DosisCalculatorJovenes.calculateSodioDosis(22.6, 120);
      expect(r['deficit_display'], '33.9 ml');
      expect(r['con_sf_display'], '881 ml');
    });
    test('clindamicina: tope 1.800 mg', () {
      expect(calc(80, 'Clindamicina')['mg'], 1067.0);
      expect(calc(150, 'Clindamicina')['mg'], 1800.0);
    });
  });

  group('TET en lactantes usa la edad en años', () {
    Map<String, dynamic> tet(int meses, String nombre) =>
        DosisCalculatorMeses.calculateDosis(
          Paciente(pesoKg: 8, edadAnios: 0, edadMeses: meses),
          Medicamento(id: '', nombre: nombre, categoria: ''),
        );
    test('11 meses → TET 4,0 / 3,5 mm, 12,5 cm (antes 7,0 mm / 17,5 cm)', () {
      expect(tet(11, 'TET sin balón')['display_string'], '4.0 mm');
      expect(tet(11, 'TET con balón')['display_string'], '3.5 mm');
      expect(
        tet(11, 'Longitud inserción a comisura labial')['display_string'],
        '12.5 cm',
      );
    });
    test('1 mes → TET 4,0 / 3,5 mm', () {
      expect(tet(1, 'TET sin balón')['display_string'], '4.0 mm');
      expect(tet(1, 'TET con balón')['display_string'], '3.5 mm');
    });
  });
}
