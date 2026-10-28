import 'package:flutter/material.dart';

import '../../../business_logic/models/kpr_result.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/status_badge.dart';

class KprResultScreen extends StatelessWidget {
  const KprResultScreen({
    super.key,
    this.result,
    this.isTahunan = false,
  });

  final KprResult? result;
  final bool isTahunan;

  KprResult get _res => result ?? KprResult.mock();

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          children: [
            _buildPaymentHeroCard(),
            const SizedBox(height: AppSizes.base),

            _buildDsrCard(),
            const SizedBox(height: AppSizes.base),

            _buildCompositionCard(),
            const SizedBox(height: AppSizes.base),

            _buildParameterSummaryCard(),
            const SizedBox(height: AppSizes.lg),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ubah Parameter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),

            GradientButton(
              text: 'Simpan Hasil Simulasi ke Riwayat',
              icon: Icons.bookmark_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Simulasi berhasil dicatat ke riwayat lokal'),
                    backgroundColor: AppColors.primaryNavy,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  // Kartu Utama Estimasi Angsuran
  Widget _buildPaymentHeroCard() {
    final nominal = isTahunan ? _res.angsuranTahunan : _res.angsuranBulanan;
    final periodeLabel = isTahunan ? '/ tahun' : '/ bulan';
    final title = isTahunan
        ? 'Estimasi Angsuran per Tahun'
        : 'Estimasi Angsuran per Bulan';

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
        children: [
          Text(
            title,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            CurrencyFormatter.formatRupiah(nominal),
            style: AppTypography.displayNominal.copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            periodeLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Text(
              'Tenor ${_res.tenorTahun} Tahun  •  Bunga ${_res.bungaTahunan.toStringAsFixed(1)}% / thn (Anuitas)',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Evaluasi Rasio Cicilan (DSR)
  Widget _buildDsrCard() {
    final isIdeal = _res.isDsrIdeal;
    final dsrPercent = _res.dsr.clamp(0.0, 100.0);

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
                  color: isIdeal
                      ? AppColors.successGreenBg
                      : AppColors.alertRedBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 22,
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
                      'Debt Service Ratio: ${_res.dsr.toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                type: isIdeal ? StatusType.murah : StatusType.mahal,
                label: isIdeal ? 'Ideal (≤ 40%)' : 'Berat (> 40%)',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.base),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rasio Cicilan Anda', style: AppTypography.captionSmall),
                  Text(
                    'Batas Aman OJK: 40%',
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dsrPercent / 100.0,
                  minHeight: 10,
                  backgroundColor: AppColors.inputSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isIdeal ? AppColors.successGreen : AppColors.alertRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: isIdeal
                  ? AppColors.successGreenBg.withValues(alpha: 0.5)
                  : AppColors.alertRedBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              _res.dsrRekomendasi,
              style: AppTypography.captionSmall.copyWith(
                color: isIdeal ? AppColors.successGreen : AppColors.alertRed,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Komposisi Pokok vs Bunga
  Widget _buildCompositionCard() {
    final flexPokok = (_res.persenPokok * 10).round().clamp(1, 1000);
    final flexBunga = (_res.persenBunga * 10).round().clamp(1, 1000);

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
          Text('Komposisi Beban Pinjaman', style: AppTypography.sectionHeader),
          const SizedBox(height: AppSizes.base),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    flex: flexPokok,
                    child: Container(color: AppColors.primaryBlue),
                  ),
                  Expanded(
                    flex: flexBunga,
                    child: Container(
                      color: AppColors.primaryBlue.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          Row(
            children: [
              _buildLegendDot(
                AppColors.primaryBlue,
                'Pokok (${_res.persenPokok.toStringAsFixed(1)}%)',
              ),
              const SizedBox(width: AppSizes.base),
              _buildLegendDot(
                AppColors.primaryBlue.withValues(alpha: 0.35),
                'Bunga (${_res.persenBunga.toStringAsFixed(1)}%)',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          _buildBreakdownRow('Total Pinjaman Pokok', _res.pinjamanPokok),
          _buildBreakdownRow('Total Estimasi Bunga', _res.totalBunga),
          const Divider(height: AppSizes.lg),
          _buildBreakdownRow(
            'Total Beban KPR (${_res.tenorTahun} Thn)',
            _res.totalPembayaran,
            isBold: true,
          ),
        ],
      ),
    );
  }

  // Ringkasan Parameter Input
  Widget _buildParameterSummaryCard() {
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
          Text('Parameter Simulasi', style: AppTypography.sectionHeader),
          const SizedBox(height: AppSizes.base),
          _buildBreakdownRow('Harga Properti', _res.hargaProperti),
          _buildBreakdownRow(
            'Uang Muka (DP ${_res.uangMukaPersen.toStringAsFixed(0)}%)',
            _res.uangMuka,
          ),
          _buildBreakdownRow('Pendapatan Bersih / Bln', _res.pendapatanBulanan),
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
          Text(
            label,
            style: isBold
                ? AppTypography.inputContent
                : AppTypography.bodyRegular,
          ),
          Text(
            CurrencyFormatter.formatRupiah(value),
            style: isBold
                ? AppTypography.inputContent.copyWith(color: AppColors.primaryBlue)
                : AppTypography.inputContent,
          ),
        ],
      ),
    );
  }
}
