import 'package:flutter_test/flutter_test.dart';
import 'package:houseprice_mobile_app/business_logic/business_logic.dart';

void main() {
  group('QA-01 & QA-02: Uji Validasi Form (Boundary Value Analysis & Equivalence Partitioning)', () {
    test('Validasi Harga Properti', () {
      expect(InputValidator.validateHarga(null), isNotNull);
      expect(InputValidator.validateHarga(''), isNotNull);
      expect(InputValidator.validateHarga('0'), isNotNull);
      expect(InputValidator.validateHarga('5.000.000'), isNotNull);
      expect(InputValidator.validateHarga('10.000.000'), isNull);
      expect(InputValidator.validateHarga('2.500.000.000'), isNull);
    });

    test('Validasi Uang Muka (DP)', () {
      const harga = 1000000000.0;
      expect(InputValidator.validateUangMuka(null, harga), isNotNull);
      expect(InputValidator.validateUangMuka('', harga), isNotNull);
      expect(InputValidator.validateUangMuka('0', harga), isNull);
      expect(InputValidator.validateUangMuka('200.000.000', harga), isNull);
      expect(InputValidator.validateUangMuka('1.000.000.000', harga), isNotNull);
      expect(InputValidator.validateUangMuka('1.500.000.000', harga), isNotNull);
    });

    test('Validasi Suku Bunga (BVA: 0.1% s/d 30.0%)', () {
      expect(InputValidator.validateBunga(null), isNotNull);
      expect(InputValidator.validateBunga(''), isNotNull);
      expect(InputValidator.validateBunga('abc'), isNotNull);
      expect(InputValidator.validateBunga('0.0'), isNotNull);
      expect(InputValidator.validateBunga('0.1'), isNull);
      expect(InputValidator.validateBunga('7.5'), isNull);
      expect(InputValidator.validateBunga('30.0'), isNull);
      expect(InputValidator.validateBunga('30.1'), isNotNull);
    });

    test('Validasi Tenor (BVA: 1 s/d 35 tahun)', () {
      expect(InputValidator.validateTenor(null), isNotNull);
      expect(InputValidator.validateTenor(''), isNotNull);
      expect(InputValidator.validateTenor('0'), isNotNull);
      expect(InputValidator.validateTenor('1'), isNull);
      expect(InputValidator.validateTenor('20'), isNull);
      expect(InputValidator.validateTenor('35'), isNull);
      expect(InputValidator.validateTenor('36'), isNotNull);
    });

    test('Validasi Luas Tanah (QA-01 BVA: min 30 m²)', () {
      expect(InputValidator.validateLuasTanah(null), isNotNull);
      expect(InputValidator.validateLuasTanah(''), isNotNull);
      expect(InputValidator.validateLuasTanah('29'), isNotNull);
      expect(InputValidator.validateLuasTanah('30'), isNull);
      expect(InputValidator.validateLuasTanah('120'), isNull);
    });
  });
}
