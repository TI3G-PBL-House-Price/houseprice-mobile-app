import 'package:flutter_test/flutter_test.dart';
import 'package:houseprice_mobile_app/business_logic/business_logic.dart';

void main() {
  group('QA-02: Uji Logika Bisnis Kalkulator KPR (Anuitas & DSR OJK)', () {
    test('Perhitungan angsuran anuitas standar bank (2 Miliar, DP 500 Jt, 7.5%, 20 Thn)', () {
      final result = KprCalculator.hitung(
        hargaProperti: 2500000000,
        uangMuka: 500000000,
        bungaTahunan: 7.5,
        tenorTahun: 20,
        pendapatanBulanan: 45000000,
      );

      expect(result.pinjamanPokok, equals(2000000000));
      expect(result.uangMukaPersen, equals(20.0));
      expect(result.angsuranBulanan, closeTo(16111894, 10000));
      expect(result.totalPembayaran, closeTo(result.angsuranBulanan * 240, 1.0));
      expect(result.totalBunga, closeTo(result.totalPembayaran - 2000000000, 1.0));
      expect(result.dsr, closeTo(35.8, 0.5));
      expect(result.isDsrIdeal, isTrue);
      expect(result.dsrStatusLabel, contains('Ideal'));
    });

    test('Evaluasi DSR OJK > 40% (Beban Berat / Berisiko)', () {
      final result = KprCalculator.hitung(
        hargaProperti: 2000000000,
        uangMuka: 200000000,
        bungaTahunan: 9.0,
        tenorTahun: 15,
        pendapatanBulanan: 20000000,
      );

      expect(result.isDsrIdeal, isFalse);
      expect(result.dsr, greaterThan(40.0));
      expect(result.dsrStatusLabel, contains('Berat'));
    });

    test('Edge case: Bunga 0% (Syariah qardh / tanpa bunga)', () {
      final result = KprCalculator.hitung(
        hargaProperti: 1200000000,
        uangMuka: 0,
        bungaTahunan: 0.0,
        tenorTahun: 10,
        pendapatanBulanan: 25000000,
      );

      expect(result.angsuranBulanan, equals(10000000));
      expect(result.totalBunga, equals(0.0));
      expect(result.totalPembayaran, equals(1200000000));
      expect(result.persenPokok, equals(100.0));
      expect(result.persenBunga, equals(0.0));
    });

    test('Edge case: DP penuh atau melebihi harga properti', () {
      final result = KprCalculator.hitung(
        hargaProperti: 1000000000,
        uangMuka: 1000000000,
        bungaTahunan: 8.0,
        tenorTahun: 10,
        pendapatanBulanan: 20000000,
      );

      expect(result.pinjamanPokok, equals(0.0));
      expect(result.angsuranBulanan, equals(0.0));
      expect(result.totalBunga, equals(0.0));
      expect(result.dsr, equals(0.0));
      expect(result.isDsrIdeal, isTrue);
    });
  });
}
