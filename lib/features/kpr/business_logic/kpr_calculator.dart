// Business Logic Layer: Kalkulator KPR & Validasi Input
// Sesuai ENGINEERING.md: logika bisnis TIDAK boleh di dalam widget build()
// Tanggung jawab: Naufal Abid Aurizky (MOB-06, MOB-07, QA-02)

// ─────────────────────────────────────────────────────────
// MODEL: Hasil perhitungan KPR
// ─────────────────────────────────────────────────────────
class KprResult {
  final double angsuranBulanan;
  final double angsuranTahunan;
  final double pokokPinjaman;
  final double totalBunga;
  final double totalPembayaran;
  final double uangMuka;
  final double dpPercentage;
  final double dsrPercentage;

  bool get isDsrAman => dsrPercentage <= 40.0;

  String get dsrLabel {
    if (dsrPercentage <= 30) return 'Sangat Baik';
    if (dsrPercentage <= 40) return 'Baik (Batas Aman OJK)';
    if (dsrPercentage <= 50) return 'Perlu Perhatian';
    return 'Melebihi Batas';
  }

  const KprResult({
    required this.angsuranBulanan,
    required this.angsuranTahunan,
    required this.pokokPinjaman,
    required this.totalBunga,
    required this.totalPembayaran,
    required this.uangMuka,
    required this.dpPercentage,
    required this.dsrPercentage,
  });

  /// Data contoh (sample/mock) sesuai design-system.md
  static const sample = KprResult(
    angsuranBulanan: 8420000,
    angsuranTahunan: 101040000,
    pokokPinjaman: 2000000000,
    totalBunga: 1020800000,
    totalPembayaran: 3020800000,
    uangMuka: 500000000,
    dpPercentage: 20.0,
    dsrPercentage: 33.7,
  );
}

// ─────────────────────────────────────────────────────────
// MODEL: Hasil cek kewajaran harga (FR-MOB-04)
// ─────────────────────────────────────────────────────────
enum StatusKewajaran { murah, wajar, mahal }

class KewajaranResult {
  final double hargaPenawaran;
  final double hargaEstimasi;
  final double deviasi;
  final StatusKewajaran status;
  final double batasWajarBawah;
  final double batasWajarAtas;

  const KewajaranResult({
    required this.hargaPenawaran,
    required this.hargaEstimasi,
    required this.deviasi,
    required this.status,
    required this.batasWajarBawah,
    required this.batasWajarAtas,
  });

  String get labelStatus {
    switch (status) {
      case StatusKewajaran.murah:
        return 'Murah / Di Bawah Pasar';
      case StatusKewajaran.wajar:
        return 'Wajar / Harga Pasar';
      case StatusKewajaran.mahal:
        return 'Mahal / Di Atas Pasar';
    }
  }

  String get saran {
    switch (status) {
      case StatusKewajaran.murah:
        return 'Harga penawaran lebih rendah dari estimasi pasar. Ini kesempatan yang baik untuk membeli!';
      case StatusKewajaran.wajar:
        return 'Harga penawaran berada dalam rentang kewajaran pasar. Transaksi dapat dipertimbangkan.';
      case StatusKewajaran.mahal:
        return 'Harga penawaran melebihi estimasi pasar. Pertimbangkan negosiasi atau cari alternatif lain.';
    }
  }
}

// ─────────────────────────────────────────────────────────
// BUSINESS LOGIC: Kalkulasi KPR Anuitas
// ─────────────────────────────────────────────────────────
class KprCalculator {
  /// Rumus: M = [P x (r/12)] / [1 - (1 + r/12)^(-n*12)]
  static KprResult hitung({
    required double hargaProperti,
    required double uangMukaRupiah,
    required double sukuBungaTahunan,
    required int tenorTahun,
    required double pendapatanBersih,
    double cicilanLainBulanan = 0,
  }) {
    final double pokok = hargaProperti - uangMukaRupiah;
    final double rBulanan = (sukuBungaTahunan / 100) / 12;
    final int totalBulan = tenorTahun * 12;
    double angsuranBulanan;

    if (rBulanan == 0) {
      angsuranBulanan = pokok / totalBulan;
    } else {
      final double faktorAtas = pokok * rBulanan;
      final double faktorBawah = 1 - (1 / _pow(1 + rBulanan, totalBulan));
      angsuranBulanan = faktorAtas / faktorBawah;
    }

    final double totalPembayaran = angsuranBulanan * totalBulan;
    final double totalBunga = totalPembayaran - pokok;
    final double dpPercentage = (uangMukaRupiah / hargaProperti) * 100;
    // DSR memperhitungkan cicilan lain yang sudah berjalan
    final double totalKewajiban = angsuranBulanan + cicilanLainBulanan;
    final double dsrPercentage =
        pendapatanBersih > 0 ? (totalKewajiban / pendapatanBersih) * 100 : 0;

    return KprResult(
      angsuranBulanan: angsuranBulanan,
      angsuranTahunan: angsuranBulanan * 12,
      pokokPinjaman: pokok,
      totalBunga: totalBunga,
      totalPembayaran: totalPembayaran,
      uangMuka: uangMukaRupiah,
      dpPercentage: dpPercentage,
      dsrPercentage: dsrPercentage,
    );
  }

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

// ─────────────────────────────────────────────────────────
// BUSINESS LOGIC: Cek Kewajaran Harga (FR-MOB-04)
// Deviasi +/-10%: Murah / Wajar / Mahal
// ─────────────────────────────────────────────────────────
class KewajaranCalculator {
  static KewajaranResult evaluasi({
    required double hargaPenawaran,
    required double estimasiMin,
    required double estimasiMax,
  }) {
    final double estimasiTengah = (estimasiMin + estimasiMax) / 2;
    final double deviasi =
        ((hargaPenawaran - estimasiTengah) / estimasiTengah) * 100;
    final double batasWajarBawah = estimasiTengah * 0.90;
    final double batasWajarAtas = estimasiTengah * 1.10;

    final StatusKewajaran status;
    if (deviasi < -10.0) {
      status = StatusKewajaran.murah;
    } else if (deviasi > 10.0) {
      status = StatusKewajaran.mahal;
    } else {
      status = StatusKewajaran.wajar;
    }

    return KewajaranResult(
      hargaPenawaran: hargaPenawaran,
      hargaEstimasi: estimasiTengah,
      deviasi: deviasi,
      status: status,
      batasWajarBawah: batasWajarBawah,
      batasWajarAtas: batasWajarAtas,
    );
  }
}

// ─────────────────────────────────────────────────────────
// VALIDASI INPUT (BVA/EP sesuai ENGINEERING.md & PRD)
// ─────────────────────────────────────────────────────────
class KprInputValidator {
  static String? hargaProperti(String? value) {
    if (value == null || value.trim().isEmpty) return 'Harga properti wajib diisi';
    final v = double.tryParse(value.replaceAll('.', ''));
    if (v == null) return 'Masukkan angka yang valid';
    if (v <= 0) return 'Harga properti harus lebih dari 0';
    return null;
  }

  static String? uangMuka(String? value, double hargaProperti) {
    if (value == null || value.trim().isEmpty) return 'Uang muka wajib diisi';
    final v = double.tryParse(value.replaceAll('.', ''));
    if (v == null) return 'Masukkan angka yang valid';
    if (v < 0) return 'Uang muka tidak boleh negatif';
    if (hargaProperti > 0 && v >= hargaProperti) {
      return 'Uang muka harus lebih kecil dari harga properti';
    }
    return null;
  }

  static String? sukuBunga(String? value) {
    if (value == null || value.trim().isEmpty) return 'Suku bunga wajib diisi';
    final v = double.tryParse(value);
    if (v == null) return 'Masukkan angka desimal yang valid (contoh: 7.5)';
    if (v <= 0) return 'Suku bunga harus lebih dari 0%';
    if (v > 30) return 'Suku bunga tidak wajar (maks. 30%)';
    return null;
  }

  static String? tenor(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tenor wajib diisi';
    final v = int.tryParse(value);
    if (v == null) return 'Masukkan bilangan bulat (tahun)';
    if (v <= 0) return 'Tenor minimal 1 tahun';
    if (v > 35) return 'Tenor maksimal 35 tahun';
    return null;
  }

  static String? pendapatanBersih(String? value) {
    if (value == null || value.trim().isEmpty) return 'Pendapatan bersih wajib diisi';
    final v = double.tryParse(value.replaceAll('.', ''));
    if (v == null) return 'Masukkan angka yang valid';
    if (v <= 0) return 'Pendapatan bersih harus lebih dari 0';
    return null;
  }

  static String? cicilanLain(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opsional
    final v = double.tryParse(value.replaceAll('.', ''));
    if (v == null) return 'Masukkan angka yang valid';
    if (v < 0) return 'Cicilan tidak boleh negatif';
    return null;
  }

  static String? hargaPenawaran(String? value) {
    if (value == null || value.trim().isEmpty) return 'Harga penawaran wajib diisi';
    final v = double.tryParse(value.replaceAll('.', ''));
    if (v == null) return 'Masukkan angka yang valid';
    if (v <= 0) return 'Harga penawaran harus lebih dari 0';
    return null;
  }
}
