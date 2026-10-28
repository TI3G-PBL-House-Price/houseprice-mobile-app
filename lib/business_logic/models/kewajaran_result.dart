import '../../core/widgets/status_badge.dart';

class KewajaranResult {
  const KewajaranResult({
    required this.hargaPenawaran,
    required this.estimasiTengah,
    required this.estimasiBatasBawah,
    required this.estimasiBatasAtas,
    required this.deviasiPersen,
    required this.selisihNominal,
    required this.status,
    required this.statusJudul,
    required this.badgeLabel,
    required this.rekomendasi,
  });

  final double hargaPenawaran;
  final double estimasiTengah;
  final double estimasiBatasBawah;
  final double estimasiBatasAtas;
  final double deviasiPersen;
  final double selisihNominal;
  final StatusType status;
  final String statusJudul;
  final String badgeLabel;
  final String rekomendasi;
}
