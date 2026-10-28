class KprResult {
  const KprResult({
    required this.hargaProperti,
    required this.uangMuka,
    required this.uangMukaPersen,
    required this.pinjamanPokok,
    required this.bungaTahunan,
    required this.tenorTahun,
    required this.pendapatanBulanan,
    required this.angsuranBulanan,
    required this.angsuranTahunan,
    required this.totalBunga,
    required this.totalPembayaran,
    required this.persenPokok,
    required this.persenBunga,
    required this.dsr,
    required this.isDsrIdeal,
    required this.dsrStatusLabel,
    required this.dsrRekomendasi,
  });

  final double hargaProperti;
  final double uangMuka;
  final double uangMukaPersen;
  final double pinjamanPokok;
  final double bungaTahunan;
  final int tenorTahun;
  final double pendapatanBulanan;
  final double angsuranBulanan;
  final double angsuranTahunan;
  final double totalBunga;
  final double totalPembayaran;
  final double persenPokok;
  final double persenBunga;
  final double dsr;
  final bool isDsrIdeal;
  final String dsrStatusLabel;
  final String dsrRekomendasi;

  factory KprResult.mock() {
    return const KprResult(
      hargaProperti: 2500000000,
      uangMuka: 500000000,
      uangMukaPersen: 20.0,
      pinjamanPokok: 2000000000,
      bungaTahunan: 7.5,
      tenorTahun: 20,
      pendapatanBulanan: 25000000,
      angsuranBulanan: 16111894,
      angsuranTahunan: 193342728,
      totalBunga: 1866854560,
      totalPembayaran: 3866854560,
      persenPokok: 51.7,
      persenBunga: 48.3,
      dsr: 33.7,
      isDsrIdeal: true,
      dsrStatusLabel: 'Ideal (≤ 40%)',
      dsrRekomendasi:
          'Rasio angsuran terhadap pendapatan Anda memenuhi rekomendasi aman Bank Indonesia & OJK (maksimal 40%).',
    );
  }
}
