import 'dart:math' as math;

import '../models/kpr_result.dart';

class KprCalculator {
  static KprResult hitung({
    required double hargaProperti,
    required double uangMuka,
    required double bungaTahunan,
    required int tenorTahun,
    required double pendapatanBulanan,
  }) {
    final pinjamanPokok = math.max(0.0, hargaProperti - uangMuka);
    final uangMukaPersen = hargaProperti > 0
        ? (uangMuka / hargaProperti) * 100
        : 0.0;

    final totalBulan = math.max(1, tenorTahun * 12);
    final i = (bungaTahunan / 100.0) / 12.0;

    double angsuranBulanan;
    if (pinjamanPokok <= 0) {
      angsuranBulanan = 0.0;
    } else if (i <= 0) {
      angsuranBulanan = pinjamanPokok / totalBulan;
    } else {
      final denominator = 1.0 - math.pow(1.0 + i, -totalBulan).toDouble();
      angsuranBulanan = (pinjamanPokok * i) / denominator;
    }

    final angsuranTahunan = angsuranBulanan * 12;
    final totalPembayaran = angsuranBulanan * totalBulan;
    final totalBunga = math.max(0.0, totalPembayaran - pinjamanPokok);

    final double persenPokok;
    final double persenBunga;
    if (totalPembayaran > 0) {
      persenPokok = (pinjamanPokok / totalPembayaran) * 100.0;
      persenBunga = (totalBunga / totalPembayaran) * 100.0;
    } else {
      persenPokok = 100.0;
      persenBunga = 0.0;
    }

    // Evaluasi Debt Service Ratio (DSR <= 40%)
    final dsr = pendapatanBulanan > 0
        ? (angsuranBulanan / pendapatanBulanan) * 100.0
        : 0.0;
    final isDsrIdeal = dsr <= 40.0;

    final String dsrStatusLabel;
    final String dsrRekomendasi;
    if (pendapatanBulanan <= 0) {
      dsrStatusLabel = 'Data Pendapatan Kosong';
      dsrRekomendasi =
          'Masukkan nominal pendapatan bulanan untuk mengevaluasi rasio kemampuan angsuran Anda.';
    } else if (isDsrIdeal) {
      dsrStatusLabel = 'Ideal (≤ 40%)';
      dsrRekomendasi =
          'Angsuran ini sehat secara finansial. Porsi cicilan ${dsr.toStringAsFixed(1)}% masih dalam koridor aman rekomendasi OJK (≤ 40%). Bank berpeluang besar menyetujui pengajuan KPR ini.';
    } else {
      dsrStatusLabel = 'Beban Berat (> 40%)';
      dsrRekomendasi =
          'Rasio cicilan ${dsr.toStringAsFixed(1)}% melampaui batas aman OJK (40%). Risiko kredit macet tinggi. Pertimbangkan menaikkan DP, memperpanjang tenor, atau mengajukan join income.';
    }

    return KprResult(
      hargaProperti: hargaProperti,
      uangMuka: uangMuka,
      uangMukaPersen: uangMukaPersen,
      pinjamanPokok: pinjamanPokok,
      bungaTahunan: bungaTahunan,
      tenorTahun: tenorTahun,
      pendapatanBulanan: pendapatanBulanan,
      angsuranBulanan: angsuranBulanan,
      angsuranTahunan: angsuranTahunan,
      totalBunga: totalBunga,
      totalPembayaran: totalPembayaran,
      persenPokok: persenPokok,
      persenBunga: persenBunga,
      dsr: dsr,
      isDsrIdeal: isDsrIdeal,
      dsrStatusLabel: dsrStatusLabel,
      dsrRekomendasi: dsrRekomendasi,
    );
  }
}
