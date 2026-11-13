import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/utils/peso_utils.dart';

void main() {
  group('parseDecimal acepta coma y punto', () {
    test('formatos válidos', () {
      expect(parseDecimal('7.5'), 7.5);
      expect(parseDecimal('7,5'), 7.5);
      expect(parseDecimal(' 22 '), 22.0);
      expect(parseDecimal('0,25'), 0.25);
    });
    test('formatos inválidos → null', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('   '), isNull);
      expect(parseDecimal('abc'), isNull);
      expect(parseDecimal('7,5,1'), isNull);
      expect(parseDecimal(null), isNull);
    });
  });

  group('Peso estimado lactantes (Excel: meses/2 + 4,5)', () {
    const casos = {1: 5.0, 3: 6.0, 6: 7.5, 9: 9.0, 11: 10.0};
    casos.forEach((meses, kg) {
      test('$meses meses → $kg kg', () {
        expect(pesoEstimadoMeses(meses), kg);
      });
    });
    test('fuera de 1–11 meses → null', () {
      expect(pesoEstimadoMeses(0), isNull);
      expect(pesoEstimadoMeses(12), isNull);
      expect(pesoEstimadoMeses(null), isNull);
    });
  });

  group('Peso estimado años (fórmula existente, sin cambios)', () {
    const casos = {1: 10.0, 4: 16.0, 5: 18.0, 10: 33.0, 14: 45.0};
    casos.forEach((anios, kg) {
      test('$anios años → $kg kg', () {
        expect(pesoEstimadoAnios(anios), kg);
      });
    });
  });

  group('Rangos de peso', () {
    test('años: 3–150 kg', () {
      expect(rangoPesoAnios.contiene(22), isTrue);
      expect(rangoPesoAnios.contiene(220), isFalse); // 22 mal tipeado
      expect(rangoPesoAnios.contiene(2.2), isFalse);
    });
    test('meses: 1–20 kg', () {
      expect(rangoPesoMeses.contiene(7.5), isTrue);
      expect(rangoPesoMeses.contiene(75), isFalse); // 7,5 mal tipeado
    });
  });
}
