import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/paciente.dart';
import '../models/medicamento.dart';

class DosisCalculator {
  static double _roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  /// Medicamentos cuya dosis es solo mg/kg (con tope opcional en mg).
  /// Sus registros no indican concentración, por lo que no se calcula ml.
  static const Map<String, (double, double?)> _dosisSoloMg = {
    'Diazepam IV.': (0.1, 10.0),
    'Valproato IV': (20.0, 1000.0),
    'Fenitoína IV.': (20.0, 1000.0),
    'Clonazepam VO': (0.01, null),
    'Tiopental': (3.0, 500.0),
    'Levetirazetam': (30.0, 4500.0),
    'Fenobarbital.': (20.0, null),
    'Paracetamol': (15.0, null),
    'Midazolam IV.': (0.15, null),
    'Metamizol IV.': (6.0, 1000.0),
  };

  /// Requerimiento basal diario (Holliday-Segar), en ml/día:
  /// 100 ml/kg los primeros 10 kg, 50 ml/kg de 10 a 20 kg y 20 ml/kg por encima.
  static double hollidaySegar(double peso) {
    if (peso <= 0) return 0.0;
    if (peso <= 10) return peso * 100;
    if (peso <= 20) return 1000 + (peso - 10) * 50;
    return 1500 + (peso - 20) * 20;
  }

  /// Redondeo según la magnitud de la dosis, para que las dosis pequeñas
  /// (lactantes) no queden en 0 ni se inflen al redondear a enteros.
  ///   < 1  → 2 decimales (0.04 ml)
  ///   < 10 → 1 decimal   (1.5 mg)
  ///   ≥ 10 → entero      (150 mg)
  static double _roundDose(double value) {
    if (value <= 0) return 0.0;
    if (value < 1) return _roundDouble(value, 2);
    if (value < 10) return _roundDouble(value, 1);
    return _roundDouble(value, 0);
  }

  /// Formatea sin ".0" sobrante (1.0 → "1", 0.25 → "0.25").
  static String _fmt(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  static Map<String, dynamic> calculateDosis(
    Paciente paciente,
    Medicamento medicamento,
  ) {
    if (medicamento.nombre.trim() == 'Adrenalina IM.') {
      return {'display_string': '0.3 ml - 0.5 ml'};
    } else if (medicamento.nombre.trim() == 'Adrenalina nebulizada') {
      return {'display_string': '0.5 mL + 3 mL SF'};
    } else if (medicamento.nombre.trim() == 'Budesonida nebulizada') {
      return {'display_string': '4 mL'};
    } else if (medicamento.nombre.trim() == 'Salbutamol neb 1-5 años') {
      return {
        'display_string':
            '0,5 ml (2,5 mg) + 2.5 cc SF ó 4puff cada 20 min (#3 neb)  Max: 7.5 mg',
      };
    } else if (medicamento.nombre.trim() == 'Salbutamol neb > 5 años') {
      return {
        'display_string': '1 ml (5mg) + 2cc SF ó 6puff cada 20 min (#3 neb)',
      };
    } else if (medicamento.nombre.trim() == 'Atrovent neb 1-5 años') {
      return {
        'display_string': '1ml (250 ug) + 2ml SF ó 2puff cada 20 min (#3 neb)',
      };
    } else if (medicamento.nombre.trim() == 'Atrovent neb > 5 años') {
      return {
        'display_string': '2ml (500 ug) + 1ml SF ó 4puff cada 20 min (#3 neb)',
      };
    } else if (medicamento.nombre.trim() == 'Catéter femoral:') {
      return {'display_string': '<2a: 4F ------13-30cm'};
    } else if (medicamento.nombre.trim() == 'Catéter yugular:') {
      return {'display_string': '2-6 a: 4F  ---- 5-8 cn'};
    } else if (medicamento.nombre.trim() == 'Catéter para drenaje pleural:') {
      return {'display_string': 'RN 6-12F'};
    } else if (medicamento.nombre.trim() == 'Ipratropium neb 1 - 5 años') {
      return {
        'display_string': '250 ug + 2.5 mg SBT + 1.5 cc sf cada 20 min (3 neb)',
      };
    } else if (medicamento.nombre.trim() == 'Ipratropium neb > 5 años') {
      return {'display_string': '500 ug + 5 mg SBT cada 20 min (3 neb)'};
    }
    double dosisMg = 0.0;
    double dosisMl = 0.0;
    double dosisJulios = 0.0;
    String displayString = '';

    if (paciente.pesoKg <= 0) {
      debugPrint('Error: El peso del paciente es nulo o cero.');
      return {'ml': 0.0, 'mg': 0.0, 'julios': 0.0};
    }

    final double peso = paciente.pesoKg;

    if (medicamento.nombre.startsWith('Adrenalina')) {
      dosisJulios = 0.0;

      if (medicamento.nombre == 'Adrenalina IV') {
        if (medicamento.categoria == 'Paro cardiaco') {
          dosisMl = (peso * 0.1).clamp(0.0, 10.0);
          dosisMg = (peso * 0.01).clamp(0.0, 1.0);
        } else if (medicamento.categoria == 'Bradiarritmias') {
          // 0,01 mg/kg; dilución 1 ml + 9 ml SF → 0,1 mg/ml. Máx 1 mg = 10 ml.
          dosisMg = (peso * 0.01).clamp(0.0, 1.0);
          dosisMl = dosisMg / 0.1;
        } else if (medicamento.categoria == 'Anafilaxia') {
          dosisMl = peso * 0.01;
          dosisMg = 0.0;
        } else {
          dosisMl = 0.0;
          dosisMg = 0.0;
        }
      } else if (medicamento.nombre == 'Adrenalina ET') {
        if (medicamento.categoria == 'Paro cardiaco') {
          // Dilución 1 ml + 9 ml SF → 0,1 mg/ml. Máx 1 mg = 10 ml.
          dosisMg = (peso * 0.1).clamp(0.0, 1.0);
          dosisMl = dosisMg / 0.1;
        } else {
          dosisMl = 0.0;
          dosisMg = 0.0;
        }
      } else if (medicamento.nombre == 'Adrenalina / Noradrenalina') {
        if (medicamento.categoria == 'Inotrópicos') {
          dosisMl = 0.0;
          dosisMg = (peso * 0.3);
          dosisJulios = 0.0;
          dosisMg = _roundDose(dosisMg);
          return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
        } else {
          dosisMl = 0.0;
          dosisMg = 0.0;
        }
      } else if (medicamento.nombre == 'Adrenalina IM') {
        if (medicamento.categoria == 'Anafilaxia') {
          if (peso > 30) {
            return {'display_string': '0.3 ml - 0.5 ml'};
          } else {
            dosisMl = peso * 0.01;
            dosisMg = 0.0;
            dosisMl = _roundDose(dosisMl);
            dosisMg = _roundDose(dosisMg);
            return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
          }
        } else {
          dosisMl = 0.0;
          dosisMg = 0.0;
        }
      } else {
        dosisMl = 0.0;
        dosisMg = 0.0;
      }

      dosisMl = _roundDouble(dosisMl, 2);
      dosisMg = _roundDouble(dosisMg, 2);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Adenosina primera' ||
        medicamento.nombre == 'Adenosina segunda' ||
        medicamento.nombre == 'Adenosina tercera') {
      // Adenosina 3 mg/ml. Máx: 6 mg (2 ml) primera; 12 mg (4 ml) siguientes.
      const double concentracionMgMl = 3.0;
      final double mgKg = medicamento.nombre == 'Adenosina primera'
          ? 0.1
          : medicamento.nombre == 'Adenosina segunda'
          ? 0.2
          : 0.3;
      final double maxMg = medicamento.nombre == 'Adenosina primera'
          ? 6.0
          : 12.0;

      dosisMg = (peso * mgKg).clamp(0.0, maxMg);
      dosisMl = dosisMg / concentracionMgMl;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Rocuronio IV') {
      dosisMl = (peso * 0.5) / 10.0;
      dosisMg = peso * 0.5;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Pancuronio') {
      dosisMl = (peso * 0.1) / 2.0;

      dosisMg = peso * 0.1;

      dosisMg = _roundDouble(dosisMg, 2);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Succinilcolina') {
      dosisMl = (peso * 1.0) / 10.0;
      dosisMg = peso * 1.0;

      dosisMg = _roundDouble(dosisMg, 2);
      dosisMl = _roundDouble(dosisMl, 2);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Atracurio') {
      dosisMl = (peso * 0.4) / 10.0;
      dosisMg = peso * 0.4;

      dosisMg = _roundDouble(dosisMg, 2);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Flumazenilo IV') {
      dosisMl = (peso * 0.01) / 0.1;
      dosisMg = peso * 0.01;
      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDouble(dosisMl, 2);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Naloxona') {
      dosisMl = (peso * 0.01) / 0.4;
      dosisMg = peso * 0.01;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Atropina') {
      // 0,02 mg/kg; dilución 2 ml + 8 ml SF → 0,1 mg/ml. Máx 1 mg = 10 ml.
      dosisMg = (peso * 0.02).clamp(0.0, 1.0);
      dosisMl = dosisMg / 0.1;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Bicarbonato de sodio 1M') {
      dosisJulios = 0.0;

      if (medicamento.categoria == 'Paro cardiaco') {
        dosisMl = (peso * 1).clamp(0.0, 100.0);
        dosisMg = (peso * 1).clamp(0.0, 100.0);

        dosisMl = _roundDouble(dosisMl, 2);
        dosisMg = _roundDouble(dosisMg, 2);

        return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
      } else if (medicamento.categoria == 'Electrolitos') {
        dosisMl = peso * 1.0;
        dosisMg = 0.0;

        dosisMl = _roundDouble(dosisMl, 2);

        return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
      } else {
        return {'display_string': 'N/A'};
      }
    } else if (medicamento.nombre == 'Sulfato de magnesio') {
      // 200 mg/ml. Máx 2 g = 10 ml.
      dosisMg = (peso * 50.0).clamp(0.0, 2000.0);
      dosisMl = dosisMg / 200.0;

      dosisMg = _roundDouble(dosisMg, 2);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Amiodarona') {
      dosisMl = (peso * 5.0 / 6.0).clamp(0.0, 50.0);

      dosisMg = (peso * 5.0).clamp(0.0, 300.0);

      dosisMg = _roundDouble(dosisMg, 2);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Midazolam IV') {
      // 5 mg/ml. Máx 15 mg = 3 ml.
      dosisMg = (peso * 0.3).clamp(0.0, 15.0);
      dosisMl = dosisMg / 5.0;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Primera descarga eléctrica') {
      dosisJulios = peso * 2.0;

      dosisJulios = _roundDose(dosisJulios);

      return {'mg': 0.0, 'ml': 0.0, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Segunda descarga eléctrica') {
      dosisJulios = peso * 4.0;

      dosisJulios = _roundDose(dosisJulios);

      return {'mg': 0.0, 'ml': 0.0, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Descarga máxima') {
      dosisJulios = peso * 10.0;

      dosisJulios = _roundDose(dosisJulios);

      return {'mg': 0.0, 'ml': 0.0, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Solución fisiológica') {
      dosisMl = peso * 20.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Crioprecipitados') {
      dosisMl = peso * 10.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Plaquetas') {
      dosisMl = peso * 10.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'GRE/PFC') {
      dosisMl = peso * 5.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Ácido tranexámico') {
      dosisMl = peso * 15.0 / 100.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Solución hipertónica') {
      dosisMl = peso * 5.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Manitol') {
      dosisMl = peso / 0.2;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Solución hipertónica.') {
      dosisMl = peso * 4.0;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Diazepam IV') {
      dosisMl = (peso * 0.3) / 5;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Diazepam VR') {
      dosisMl = (peso * 0.5) / 5;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Midazolam IV o IM') {
      dosisMl = (peso * 0.3) / 5;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Solución mixta mantenimiento') {
      dosisMl = _roundDose(hollidaySegar(peso));
      return {'mg': 0.0, 'ml': dosisMl, 'julios': 0.0};
    } else if (medicamento.nombre == 'SG 25%') {
      dosisMl = (peso * 2);
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Sol glucosada mayor 1 mes edad') {
      final double dosisEnMg = peso * 0.5;
      final double dosisRedondeada = _roundDose(dosisEnMg);

      displayString = '${_fmt(dosisRedondeada)} g';

      return {
        'ml': 0.0,
        'mg': dosisEnMg,
        'julios': 0.0,
        'display_string': displayString,
      };
    } else if (medicamento.nombre == 'Midazolam IN') {
      dosisMl = (peso * 0.4) / 5;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Fenitoína IV') {
      dosisMl = (peso * 20) / 50;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Fenobarbital') {
      dosisMl = (peso * 20) / 50;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Paracetamol oral IV') {
      dosisMg = (peso * 15.0).clamp(0.0, 1000.0);
      dosisMl = 0.0;
      dosisJulios = 0.0;
      dosisMg = _roundDouble(dosisMg, 2);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Metamizol IV') {
      dosisMg = (peso * 15.0).clamp(0.0, 1000.0);
      dosisMl = 0.0;
      dosisJulios = 0.0;
      dosisMg = _roundDouble(dosisMg, 2);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Ibuprofeno VO') {
      dosisMg = (peso * 10.0).clamp(0.0, 400.0);
      dosisMl = 0.0;
      dosisJulios = 0.0;
      dosisMg = _roundDouble(dosisMg, 2);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Dexametasona IV') {
      dosisMl = (peso * 0.6) / 4;
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Dexametazona') {
      dosisMl = 0.0;
      dosisMg = (peso * 0.1);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Hidrocortisona IV') {
      dosisMl = 0.0;
      dosisMg = (peso * 4).clamp(0.0, 100.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Metilprednisolona') {
      dosisMl = 0.0;
      dosisMg = (peso * 2).clamp(0.0, 60.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Sulf magnesio IV bolus') {
      dosisMl = 0.0;
      dosisMg = (peso * 50).clamp(0.0, 2000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Sol hipertónica 3%') {
      // Volumen en ml/kg (2-5 ml/kg): no se expresa en mg.
      dosisMl = _roundDose(peso * 3);
      return {'mg': 0.0, 'ml': dosisMl, 'julios': 0.0};
    } else if (_dosisSoloMg.containsKey(medicamento.nombre)) {
      // Sin concentración definida en los datos → solo se muestran mg.
      // (Antes se devolvía ml = mg, p. ej. "600 ml 600 mg".)
      final (mgKg, maxMg) = _dosisSoloMg[medicamento.nombre]!;
      dosisMg = peso * mgKg;
      if (maxMg != null) dosisMg = dosisMg.clamp(0.0, maxMg);
      return {'mg': _roundDose(dosisMg), 'ml': 0.0, 'julios': 0.0};
    } else if (medicamento.nombre == 'Ampicilina') {
      dosisMl = 0.0;
      dosisMg = (peso * 50).clamp(0.0, 3000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Cefotaxima') {
      dosisMl = 0.0;
      dosisMg = ((peso * 200) / 4).clamp(0.0, 4000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Ceftazidime') {
      dosisMl = 0.0;
      dosisMg = (peso * 50);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Meropenem') {
      dosisMl = 0.0;
      dosisMg = ((peso * 60) / 3).clamp(0.0, 2000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Vancomicina') {
      dosisMl = 0.0;
      dosisMg = (peso * 15).clamp(0.0, 500.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Aciclovir') {
      dosisMl = 0.0;
      dosisMg = ((peso * 60) / 3).clamp(0.0, 1000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Ceftriaxona') {
      dosisMl = 0.0;
      dosisMg = (peso * 100).clamp(0.0, 4000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Pipe-tazo') {
      dosisMl = 0.0;
      dosisMg = ((peso * 300) / 4).clamp(0.0, 3500.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Amoxi-clav') {
      dosisMl = 0.0;
      dosisMg = ((peso * 90) / 2).clamp(0.0, 1000.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Amikacina') {
      dosisMl = 0.0;
      dosisMg = ((peso * 22.5) / 3).clamp(0.0, 1500.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Clindamicina') {
      dosisMl = 0.0;
      // Tope 1,8 g por dosis, igual que la tabla Excel "para APP".
      dosisMg = ((peso * 40) / 3).clamp(0.0, 1800.0);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Morfina') {
      dosisMl = 0.0;
      dosisMg = (peso * 1.5);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Midazolam') {
      dosisMl = 0.0;
      dosisMg = (peso * 6);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Dopamina / Dobutamina') {
      dosisMl = 0.0;
      dosisMg = (peso * 15);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Gluconato de calcio 10%') {
      dosisMg = 0.0;
      dosisJulios = 0.0;

      if (medicamento.categoria == 'Calcio de mantenimiento') {
        dosisMl = (peso * 2).clamp(0.0, 2000.0);
      } else if (medicamento.categoria == 'Electrolitos' ||
          medicamento.categoria ==
              'Hipocalcemia severa, Hipermagnesemia ó Intoxicación con bloqueadores de los canales de calcio') {
        dosisMl = ((peso * 50) / 100).clamp(0.0, 2000.0);
      } else {
        dosisMl = 0.0;
      }
      dosisMl = _roundDouble(dosisMl, 2);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Cloruro de calcio 10%') {
      dosisMl = ((peso * 10) / 100).clamp(0.0, 1000.0);
      dosisMg = 0.0;
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Fentanilo') {
      final double dosisUg = 250 * peso;
      dosisMg = 0.0;
      dosisMl = 0.0;
      dosisJulios = 0.0;

      return {'display_string': '${_fmt(_roundDose(dosisUg))} µg'};
    } else if (medicamento.nombre == 'Volumen de SF') {
      final double dosisMl = _roundDose((peso * 0.5 * 1000) / 40);
      final double dosisMeq = peso * 1;

      return {
        'display_string': '${dosisMl.round()} ml, ${dosisMeq.round()} mEq',
      };
    } else if (medicamento.nombre == 'Insulina simple') {
      final double resultadoFormula = peso * 0.1;

      if (medicamento.categoria == 'Endocrino / Renal') {
        dosisMg = 0.0;
        dosisMl = 0.0;
        dosisJulios = 0.0;
        return {'display_string': '${_fmt(_roundDose(resultadoFormula))} UI'};
      } else if (medicamento.categoria == 'Electrolitos') {
        dosisMg = 0.0;
        dosisMl = _roundDose(resultadoFormula);
        dosisJulios = 0.0;
        return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
      } else {
        return {'display_string': 'N/A'};
      }
    } else if (medicamento.nombre == 'Furosemida') {
      dosisMl = 0.0;
      dosisMg = (peso * 0.5);
      dosisJulios = 0.0;
      dosisMg = _roundDose(dosisMg);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Solución glucosada al 10%') {
      dosisMg = 0.0;
      dosisMl = (peso * 5);
      dosisJulios = 0.0;
      dosisMl = _roundDose(dosisMl);
      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Morfina.') {
      // 15 mg + 14 ml SF → 1 mg/ml. Máx 10 ml = 10 mg.
      dosisMg = (peso * 0.1).clamp(0.0, 10.0);
      dosisMl = dosisMg;
      dosisJulios = 0.0;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Fentanilo.') {
      final double dosisUg = peso * 2;
      final double dosisMl = (dosisUg / 50).clamp(0.0, 50.0);

      return {
        'display_string':
            '${_fmt(_roundDose(dosisMl))} ml, ${_fmt(_roundDose(dosisUg))} µg',
      };
    } else if (medicamento.nombre == 'Ketamina') {
      dosisMl = (peso * 1) / 10;
      dosisMg = (peso * 1);
      dosisJulios = 0.0;

      dosisMg = _roundDose(dosisMg);
      dosisMl = _roundDose(dosisMl);

      return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
    } else if (medicamento.nombre == 'Salbutamol nebulizado') {
      double dosisMl;
      double dosisMg;

      if (peso <= 25) {
        dosisMl = 0.5;
        dosisMg = 2.5;
      } else {
        dosisMl = 1;
        dosisMg = 5;
      }
      return {'ml': dosisMl, 'mg': dosisMg, 'julios': 0.0};
    }

    if (medicamento.dosisBaseMgKg != null) {
      dosisMg = medicamento.dosisBaseMgKg! * peso;
      double concentracionParaMl = 1.0;
      if (medicamento.factorDilucion != null &&
          medicamento.factorDilucion! > 0) {
        concentracionParaMl = 1000 / medicamento.factorDilucion!;
      }
      dosisMl = dosisMg / concentracionParaMl;
    } else if (medicamento.dosisBaseMlKg != null) {
      dosisMl = medicamento.dosisBaseMlKg! * peso;
      dosisMg = 0.0;
    } else if (medicamento.dosisFijaMl != null) {
      dosisMl = medicamento.dosisFijaMl!;
      dosisMg = 0.0;
    } else if (medicamento.dosisFijaMg != null) {
      dosisMg = medicamento.dosisFijaMg!;
      dosisMl = 0.0;
    } else {
      debugPrint(
        'Advertencia: No se ha definido un cálculo de dosis específico para ${medicamento.nombre}',
      );
    }

    dosisMg = _roundDouble(dosisMg, 2);
    dosisMl = _roundDouble(dosisMl, 2);

    return {'mg': dosisMg, 'ml': dosisMl, 'julios': dosisJulios};
  }
}
