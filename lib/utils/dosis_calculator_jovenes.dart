import 'dart:math';

import 'calc_messages.dart';

class DosisCalculatorJovenes {
  static Map<String, String> calculateLiquidosIvDosis(
    double pesoKg,
    double porcentaje,
  ) {
    if (pesoKg <= 0 || porcentaje <= 0) {
      return {
        'solucion_mixta': 'N/A',
        'resultado': 'N/A',
        'goteo_ml_h': 'N/A',
        'goteo_ml_h_ajustado': 'N/A',
      };
    }
    double requerimientoTotal = 0.0;
    if (pesoKg < 10) {
      requerimientoTotal = pesoKg * 100;
    } else if (pesoKg >= 10 && pesoKg < 20) {
      requerimientoTotal = (10 * 100) + ((pesoKg - 10) * 50);
    } else {
      requerimientoTotal = (10 * 100) + (10 * 50) + ((pesoKg - 20) * 20);
    }

    double resultado = (requerimientoTotal * porcentaje) / 100;
    double goteoMlH = resultado / 24;

    return {
      'solucion_mixta': '${requerimientoTotal.toStringAsFixed(2)} cc',
      'resultado': '${resultado.toStringAsFixed(2)} cc',
      'goteo_ml_h': '${goteoMlH.toStringAsFixed(2)} ml/h',
      'goteo_ml_h_ajustado':
          '${_roundDouble(goteoMlH / 3, 2).toStringAsFixed(2)} ml/h',
    };
  }

  static double _roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  static Map<String, String> calculateSodioDosis(
    double peso,
    double sodioDelPaciente,
  ) {
    const double constante = 0.6;
    const double factor = 4;
    const double mil = 1000;

    if (sodioDelPaciente <= 0 || peso <= 0) {
      return {
        'deficit_display': CalcMsg.needSodium,
        'volumen_display': 'N/A',
        'velocidad_display': 'N/A',
        'con_sf_display': 'N/A',
      };
    }
    if (sodioDelPaciente >= 130) {
      return {
        'deficit_display': CalcMsg.noSodiumDeficit,
        'volumen_display': 'N/A',
        'velocidad_display': 'N/A',
        'con_sf_display': 'N/A',
      };
    }

    // Déficit de Sodio
    double deficitSodio =
        ((130 - sodioDelPaciente) * peso * constante) / factor;
    deficitSodio = _roundDouble(deficitSodio, 1);

    // Volumen de SG5%
    double volumenSG5 = deficitSodio * 7;
    volumenSG5 = _roundDouble(volumenSG5, 1);

    // Velocidad de Infusión
    final double dosisConSF = volumenSG5 / 3;
    final int dosisEntera = dosisConSF.round();

    // Con SF
    double conSF = ((130 - sodioDelPaciente) * peso * constante) / 154 * mil;
    conSF = _roundDouble(conSF, 0);

    return {
      'deficit_display': '${deficitSodio.toStringAsFixed(1)} ml',
      'volumen_display': '${volumenSG5.toStringAsFixed(1)} ml',
      'velocidad_display': '$dosisEntera ml/h',
      'con_sf_display': '${conSF.toStringAsFixed(0)} ml',
    };
  }

  static Map<String, String> calculateHco3Dosis(
    double peso,
    double hco3DelPaciente,
  ) {
    const double constante = 0.5;

    if (hco3DelPaciente <= 0 || peso <= 0) {
      return {
        'deficit_display': CalcMsg.needHco3,
        'volumen_display': 'N/A',
        'velocidad_display': 'N/A',
      };
    }
    if (hco3DelPaciente >= 15) {
      return {
        'deficit_display': CalcMsg.noHco3Deficit,
        'volumen_display': 'N/A',
        'velocidad_display': 'N/A',
      };
    }

    double deficitHco3 = (15 - hco3DelPaciente) * peso * constante;
    deficitHco3 = _roundDouble(deficitHco3, 1);

    double volumenSG5 = deficitHco3 * 7;
    volumenSG5 = _roundDouble(volumenSG5, 1);

    double velocidadInfusion = volumenSG5 / 3;
    velocidadInfusion = _roundDouble(velocidadInfusion, 1);

    return {
      'deficit_display': '${deficitHco3.toStringAsFixed(1)} ml',
      'volumen_display': '${volumenSG5.toStringAsFixed(1)} ml',
      'velocidad_display': '${velocidadInfusion.toStringAsFixed(1)} ml/h',
    };
  }
}
