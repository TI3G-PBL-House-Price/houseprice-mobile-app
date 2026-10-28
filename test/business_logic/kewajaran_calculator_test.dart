import 'package:flutter_test/flutter_test.dart';
import 'package:houseprice_mobile_app/business_logic/business_logic.dart';
import 'package:houseprice_mobile_app/core/widgets/status_badge.dart';

void main() {
  group('QA-02: Uji Logika Bisnis Cek Kewajaran Harga (Deviasi ±10%)', () {
    const estimasiTengah = 2000000000.0;

    test('Status Murah: Deviasi < -10% (Penawaran Rp 1.700.000.000 / -15%)', () {
      final result = KewajaranCalculator.evaluasi(
        hargaPenawaran: 1700000000,
        estimasiTengah: estimasiTengah,
      );

      expect(result.status, equals(StatusType.murah));
      expect(result.deviasiPersen, equals(-15.0));
      expect(result.selisihNominal, equals(-300000000));
      expect(result.estimasiBatasBawah, equals(1800000000));
      expect(result.estimasiBatasAtas, equals(2200000000));
      expect(result.statusJudul, contains('Murah'));
      expect(result.badgeLabel, contains('Murah (-15.0%)'));
    });

    test('Status Wajar: Deviasi tepat pada batas toleransi (-10% s/d +10%)', () {
      final resultTepat = KewajaranCalculator.evaluasi(
        hargaPenawaran: 2000000000,
        estimasiTengah: estimasiTengah,
      );
      expect(resultTepat.status, equals(StatusType.wajar));
      expect(resultTepat.deviasiPersen, equals(0.0));
      expect(resultTepat.badgeLabel, contains('Wajar (+0.0%)'));

      final resultBatasBawah = KewajaranCalculator.evaluasi(
        hargaPenawaran: 1800000000,
        estimasiTengah: estimasiTengah,
      );
      expect(resultBatasBawah.status, equals(StatusType.wajar));
      expect(resultBatasBawah.deviasiPersen, equals(-10.0));

      final resultBatasAtas = KewajaranCalculator.evaluasi(
        hargaPenawaran: 2200000000,
        estimasiTengah: estimasiTengah,
      );
      expect(resultBatasAtas.status, equals(StatusType.wajar));
      expect(resultBatasAtas.deviasiPersen, equals(10.0));
    });

    test('Status Mahal: Deviasi > +10% (Penawaran Rp 2.400.000.000 / +20%)', () {
      final result = KewajaranCalculator.evaluasi(
        hargaPenawaran: 2400000000,
        estimasiTengah: estimasiTengah,
      );

      expect(result.status, equals(StatusType.mahal));
      expect(result.deviasiPersen, equals(20.0));
      expect(result.selisihNominal, equals(400000000));
      expect(result.statusJudul, contains('Mahal'));
      expect(result.badgeLabel, contains('Mahal (+20.0%)'));
    });
  });
}
