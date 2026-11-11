import 'package:flutter_test/flutter_test.dart';
import 'package:houseprice_mobile_app/features/kpr/business_logic/kpr_calculator.dart';
import 'package:houseprice_mobile_app/features/kpr/utils/currency_formatter.dart';

void main() {
  group('Kalkulator KPR (FR-MOB-05 / QA-02) Tests', () {
    test('Perhitungan anuitas KPR standar menghasilkan nominal yang akurat', () {
      final res = KprCalculator.hitung(
        hargaProperti: 1000000000,
        uangMukaRupiah: 200000000, // DP 20%
        sukuBungaTahunan: 6.0,
        tenorTahun: 20,
        pendapatanBersih: 20000000,
      );

      // Pokok pinjaman 800 juta
      expect(res.pokokPinjaman, 800000000);
      expect(res.dpPercentage, 20.0);
      expect(res.angsuranBulanan, greaterThan(5000000));
      expect(res.angsuranBulanan, lessThan(6000000));
      expect(res.angsuranTahunan, res.angsuranBulanan * 12);
      expect(res.totalPembayaran, greaterThan(res.pokokPinjaman));
      expect(res.totalBunga, res.totalPembayaran - res.pokokPinjaman);
    });

    test('Evaluasi DSR OJK: DSR <= 40% tergolong aman', () {
      final aman = KprCalculator.hitung(
        hargaProperti: 500000000,
        uangMukaRupiah: 100000000,
        sukuBungaTahunan: 5.0,
        tenorTahun: 20,
        pendapatanBersih: 15000000,
      );
      expect(aman.isDsrAman, isTrue);
      expect(aman.dsrPercentage, lessThanOrEqualTo(40.0));

      final bahaya = KprCalculator.hitung(
        hargaProperti: 2000000000,
        uangMukaRupiah: 200000000,
        sukuBungaTahunan: 10.0,
        tenorTahun: 10,
        pendapatanBersih: 10000000,
      );
      expect(bahaya.isDsrAman, isFalse);
      expect(bahaya.dsrPercentage, greaterThan(40.0));
    });

    test('DSR memperhitungkan cicilan lain yang sedang berjalan', () {
      final res = KprCalculator.hitung(
        hargaProperti: 500000000,
        uangMukaRupiah: 100000000,
        sukuBungaTahunan: 6.0,
        tenorTahun: 20,
        pendapatanBersih: 10000000,
        cicilanLainBulanan: 2000000,
      );
      // Total kewajiban = angsuran + 2 juta
      expect(res.dsrPercentage, greaterThan((res.angsuranBulanan / 10000000) * 100));
    });
  });

  group('Cek Kewajaran Harga (FR-MOB-04 / QA-02) Tests', () {
    test('Status Murah jika deviasi < -10%', () {
      final res = KewajaranCalculator.evaluasi(
        hargaPenawaran: 1500000000,
        estimasiMin: 1800000000,
        estimasiMax: 2200000000, // Tengah = 2.000.000.000
      );
      expect(res.status, StatusKewajaran.murah);
      expect(res.deviasi, lessThan(-10.0));
      expect(res.labelStatus, contains('Murah'));
    });

    test('Status Wajar jika deviasi berada dalam rentang -10% hingga +10%', () {
      final res = KewajaranCalculator.evaluasi(
        hargaPenawaran: 2050000000,
        estimasiMin: 1800000000,
        estimasiMax: 2200000000, // Tengah = 2.000.000.000
      );
      expect(res.status, StatusKewajaran.wajar);
      expect(res.deviasi, inInclusiveRange(-10.0, 10.0));
      expect(res.labelStatus, contains('Wajar'));
    });

    test('Status Mahal jika deviasi > +10%', () {
      final res = KewajaranCalculator.evaluasi(
        hargaPenawaran: 2500000000,
        estimasiMin: 1800000000,
        estimasiMax: 2200000000, // Tengah = 2.000.000.000
      );
      expect(res.status, StatusKewajaran.mahal);
      expect(res.deviasi, greaterThan(10.0));
      expect(res.labelStatus, contains('Mahal'));
    });
  });

  group('Validasi Input (BVA/EP sesuai PRD) Tests', () {
    test('Validasi harga properti', () {
      expect(KprInputValidator.hargaProperti(null), isNotNull);
      expect(KprInputValidator.hargaProperti(''), isNotNull);
      expect(KprInputValidator.hargaProperti('0'), isNotNull);
      expect(KprInputValidator.hargaProperti('-100'), isNotNull);
      expect(KprInputValidator.hargaProperti('800.000.000'), isNull);
    });

    test('Validasi uang muka (DP)', () {
      expect(KprInputValidator.uangMuka('100.000.000', 500000000), isNull);
      expect(KprInputValidator.uangMuka('600.000.000', 500000000), isNotNull); // DP >= Harga
    });

    test('Validasi suku bunga', () {
      expect(KprInputValidator.sukuBunga('0'), isNotNull);
      expect(KprInputValidator.sukuBunga('35'), isNotNull); // max 30%
      expect(KprInputValidator.sukuBunga('6.5'), isNull);
    });

    test('Validasi tenor', () {
      expect(KprInputValidator.tenor('0'), isNotNull);
      expect(KprInputValidator.tenor('40'), isNotNull); // max 35 tahun
      expect(KprInputValidator.tenor('20'), isNull);
    });
  });

  group('CurrencyFormatter Tests', () {
    test('formatRupiah formatting', () {
      expect(CurrencyFormatter.formatRupiah(1000000), 'Rp 1.000.000');
      expect(CurrencyFormatter.formatCompact(1500000000), 'Rp 1.5 M');
      expect(CurrencyFormatter.formatCompact(25000000), 'Rp 25.0 Juta');
    });
  });
}

