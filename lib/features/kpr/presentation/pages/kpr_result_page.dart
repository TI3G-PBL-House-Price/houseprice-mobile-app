import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';
import '../../business_logic/kpr_calculator.dart';
import '../../utils/currency_formatter.dart';

/// Layar Hasil Simulasi KPR (FR-MOB-05 Result).
/// Referensi: design-system.md § 4B – Layar Hasil KPR
/// Menerima KprResult dari KprFormPage (tidak lagi mock data).
/// Tanggung jawab: Naufal Abid Aurizky
class KprResultPage extends StatelessWidget {
  const KprResultPage({
    super.key,
    this.result = KprResult.sample,
    this.hargaProperti = 2500000000,
    this.sukuBunga = 6.5,
    this.tenor = 20,
    this.pendapatanBersih = 25000000,
    this.showTahunan = false,
  });

  final KprResult result;
  final double hargaProperti;
  final double sukuBunga;
  final int tenor;
  final double pendapatanBersih;
  final bool showTahunan;

  // Format helpers
  String _fmt(double v) => CurrencyFormatter.formatRupiah(v);
  String _fmtCompact(double v) => CurrencyFormatter.formatCompact(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Simulasi KPR', style: AppTypography.sectionHeader),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Riwayat',
            onPressed: () => HistoryBottomSheet.show(context),
          ),
          const SizedBox(width: AppSizes.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          children: [
            // ── Hero: Angsuran ───────────────────────────────────────────
            _buildAngsuranCard(),
            const SizedBox(height: AppSizes.base),

            // ── Analisis DSR ─────────────────────────────────────────────
            _buildDsrCard(),
            const SizedBox(height: AppSizes.base),

            // ── Komposisi Pokok vs Bunga ─────────────────────────────────
            _buildCompositionCard(),
            const SizedBox(height: AppSizes.base),

            // ── Ringkasan Input ──────────────────────────────────────────
            _buildRingkasanCard(context),
            const SizedBox(height: AppSizes.base),

            // ── Disclaimer ───────────────────────────────────────────────
            _buildDisclaimer(),
            const SizedBox(height: AppSizes.lg),

            // ── Hitung Ulang ─────────────────────────────────────────────
            GradientButton(
              text: 'Hitung Ulang',
              icon: Icons.refresh_rounded,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  // ── CARD 1: Hero Angsuran ──────────────────────────────────────────────────
  Widget _buildAngsuranCard() {
    final angsuran =
        showTahunan ? result.angsuranTahunan : result.angsuranBulanan;
    final labelPeriode = showTahunan ? 'Angsuran Tahunan' : 'Angsuran Bulanan';
    final subLabel = showTahunan
        ? '${_fmtCompact(result.angsuranBulanan)} per bulan'
        : '${_fmtCompact(result.angsuranTahunan)} per tahun';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelPeriode,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _fmt(angsuran),
            style: AppTypography.displayNominal.copyWith(color: AppColors.white),
          ),
          Text(
            subLabel,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSizes.base),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              _chip('DP ${result.dpPercentage.toStringAsFixed(0)}%',
                  Icons.account_balance_wallet_rounded),
              _chip('$sukuBunga% p.a.', Icons.percent_rounded),
              _chip('$tenor Tahun', Icons.calendar_today_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.white.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.white, size: 11),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── CARD 2: DSR OJK ───────────────────────────────────────────────────────
  Widget _buildDsrCard() {
    final isIdeal = result.isDsrAman;
    final Color statusColor = result.dsrPercentage <= 30
        ? AppColors.successGreen
        : result.dsrPercentage <= 40
            ? AppColors.infoBlue
            : AppColors.alertRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: isIdeal ? AppColors.successGreenBg : AppColors.alertRedBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: AppSizes.iconMd,
                  color: isIdeal ? AppColors.successGreen : AppColors.alertRed,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evaluasi Kapasitas Bayar (DSR)',
                        style: AppTypography.sectionHeader),
                    const SizedBox(height: 2),
                    Text(
                      'Debt Service Ratio: ${result.dsrPercentage.toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                type: result.dsrPercentage <= 30
                    ? StatusType.murah
                    : result.dsrPercentage <= 40
                        ? StatusType.wajar
                        : StatusType.mahal,
                label: result.dsrLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.base),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (result.dsrPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.inputSurface,
              color: statusColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            isIdeal
                ? 'Cicilan ${result.dsrPercentage.toStringAsFixed(1)}% dari pendapatan — masih dalam batas OJK (≤40%)'
                : 'Cicilan melebihi batas rekomendasi OJK 40%. Pertimbangkan menambah DP atau memperpanjang tenor.',
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dsrInfo('Pendapatan Bersih', _fmtCompact(pendapatanBersih)),
              _dsrInfo('Angsuran/Bulan', _fmtCompact(result.angsuranBulanan)),
              _dsrInfo('Pinjaman Pokok', _fmtCompact(result.pokokPinjaman)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dsrInfo(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTypography.captionSmall
              .copyWith(color: AppColors.textSecondary)),
      Text(value,
          style: AppTypography.caption
              .copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }

  // ── CARD 3: Komposisi Angsuran ────────────────────────────────────────────
  Widget _buildCompositionCard() {
    final pPct = result.totalPembayaran > 0
        ? (result.pokokPinjaman / result.totalPembayaran * 100).round()
        : 50;
    final bPct = 100 - pPct;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Komposisi Angsuran', style: AppTypography.sectionHeader),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.inputSurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
              child: Text('${tenor * 12} Bulan',
                  style: AppTypography.captionSmall
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: AppSizes.base),

          // Proportion bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    flex: pPct * 10,
                    child: Container(color: AppColors.primaryBlue),
                  ),
                  Expanded(
                    flex: bPct * 10,
                    child: Container(
                        color: AppColors.primaryBlue.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Legend
          Row(
            children: [
              _buildLegendDot(AppColors.primaryBlue, 'Pokok ($pPct%)'),
              const SizedBox(width: AppSizes.base),
              _buildLegendDot(
                  AppColors.primaryBlue.withValues(alpha: 0.35), 'Bunga ($bPct%)'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Breakdown
          _buildBreakdownRow('Total Pinjaman Pokok', result.pokokPinjaman),
          _buildBreakdownRow('Total Estimasi Bunga', result.totalBunga),
          const Divider(height: AppSizes.lg),
          _buildBreakdownRow('Total Beban KPR', result.totalPembayaran,
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.xs),
        Text(label, style: AppTypography.captionSmall),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? AppTypography.inputContent
                  : AppTypography.bodyRegular),
          Text(
            _fmt(value),
            style: isBold
                ? AppTypography.inputContent
                    .copyWith(color: AppColors.primaryBlue)
                : AppTypography.inputContent,
          ),
        ],
      ),
    );
  }

  // ── CARD 4: Ringkasan Input ───────────────────────────────────────────────
  Widget _buildRingkasanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Data Input', style: AppTypography.sectionHeader),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryBlue),
                label: Text('Ubah',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _detailRow('Harga Properti', _fmt(hargaProperti)),
          _detailRow(
              'Uang Muka (DP ${result.dpPercentage.toStringAsFixed(0)}%)',
              _fmt(result.uangMuka)),
          _detailRow(
              'Plafon Pokok Pinjaman', _fmt(result.pokokPinjaman)),
          _detailRow('Suku Bunga KPR', '$sukuBunga% Fixed p.a.'),
          _detailRow(
              'Jangka Waktu', '$tenor Tahun (${tenor * 12} Bulan)'),
          _detailRow('Pendapatan Bersih',
              '${_fmt(pendapatanBersih)} /bln'),
          _detailRow('Metode Perhitungan', 'Bunga Anuitas Tetap'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 4,
            child: Text(label,
                style: AppTypography.captionSmall
                    .copyWith(color: AppColors.textSecondary, height: 1.4))),
        Expanded(
            flex: 5,
            child: Text(value,
                style: AppTypography.caption
                    .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                textAlign: TextAlign.right)),
      ]),
    );
  }

  // ── Disclaimer ────────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Simulasi ini merupakan estimasi indikatif berdasarkan metode bunga anuitas. Suku bunga dan ketentuan persetujuan akhir mengikuti kebijakan penilaian risiko masing-masing bank yang diawasi oleh Otoritas Jasa Keuangan (OJK).',
              style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias KprResultScreen agar kompatibel dengan penamaan lama.
typedef KprResultScreen = KprResultPage;
