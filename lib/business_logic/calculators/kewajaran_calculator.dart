import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../models/kewajaran_result.dart';

class KewajaranCalculator {
  static const double batasToleransiPersen = 10.0;

  static KewajaranResult evaluasi({
    required double hargaPenawaran,
    required double estimasiTengah,
  }) {
    if (estimasiTengah <= 0) {
      return KewajaranResult(
        hargaPenawaran: hargaPenawaran,
        estimasiTengah: 0,
        estimasiBatasBawah: 0,
        estimasiBatasAtas: 0,
        deviasiPersen: 0,
        selisihNominal: 0,
        status: StatusType.wajar,
        statusJudul: 'Estimasi Belum Tersedia',
        badgeLabel: 'Data Tidak Lengkap',
        rekomendasi:
            'Nilai estimasi pasar belum dapat dihitung. Pastikan spesifikasi properti telah diisi dengan benar.',
      );
    }

    final batasBawah = estimasiTengah * (1.0 - (batasToleransiPersen / 100.0));
    final batasAtas = estimasiTengah * (1.0 + (batasToleransiPersen / 100.0));
    final selisihNominal = hargaPenawaran - estimasiTengah;
    final deviasiPersen = (selisihNominal / estimasiTengah) * 100.0;

    final StatusType status;
    final String statusJudul;
    final String badgeLabel;
    final String rekomendasi;

    final batasBawahStr = CurrencyFormatter.formatRupiah(batasBawah);
    final batasAtasStr = CurrencyFormatter.formatRupiah(batasAtas);

    // Kategori deviasi: Murah (< -10%), Wajar (-10% s/d +10%), Mahal (> +10%)
    if (deviasiPersen < -batasToleransiPersen) {
      status = StatusType.murah;
      statusJudul = 'Murah / Di Bawah Pasar';
      badgeLabel = 'Murah (-${deviasiPersen.abs().toStringAsFixed(1)}%)';
      rekomendasi =
          'Harga penawaran ini berada di bawah rentang pasar wajar ($batasBawahStr – $batasAtasStr). '
          'Ini merupakan peluang beli yang sangat baik, namun disarankan tetap memeriksa kelengkapan legalitas (SHM/IMB) dan kondisi fisik bangunan.';
    } else if (deviasiPersen <= batasToleransiPersen) {
      status = StatusType.wajar;
      statusJudul = 'Wajar / Sesuai Pasar';
      final tanda = deviasiPersen >= 0 ? '+' : '';
      badgeLabel = 'Wajar ($tanda${deviasiPersen.toStringAsFixed(1)}%)';
      rekomendasi =
          'Harga penawaran berada di dalam koridor toleransi wajar pasar ($batasBawahStr – $batasAtasStr). '
          'Penawaran penjual dinilai proporsional dan kompetitif untuk kawasan ini.';
    } else {
      status = StatusType.mahal;
      statusJudul = 'Mahal / Di Atas Pasar';
      badgeLabel = 'Mahal (+${deviasiPersen.toStringAsFixed(1)}%)';
      rekomendasi =
          'Harga penawaran ini melampaui batas atas pasar wajar ($batasBawahStr – $batasAtasStr) sebesar ${deviasiPersen.toStringAsFixed(1)}%. '
          'Disarankan bernegosiasi turun setidaknya ke rentang pasar wajar sebelum memutuskan transaksi.';
    }

    return KewajaranResult(
      hargaPenawaran: hargaPenawaran,
      estimasiTengah: estimasiTengah,
      estimasiBatasBawah: batasBawah,
      estimasiBatasAtas: batasAtas,
      deviasiPersen: deviasiPersen,
      selisihNominal: selisihNominal,
      status: status,
      statusJudul: statusJudul,
      badgeLabel: badgeLabel,
      rekomendasi: rekomendasi,
    );
  }
}
