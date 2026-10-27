import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';

/// Layar Hasil Simulasi KPR (FR-MOB-05 Result).
/// Referensi: design-system.md § 4B – Layar Hasil KPR
class KprResultPage extends StatelessWidget {
  const KprResultPage({super.key});

  // ── Mock Data ──────────────────────────────────────────────────────────────
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static const int _mockMonthlyPayment = 8420000;
  static const int _mockTotalLoan = 2000000000;
  static const int _mockTotalInterest = 1020800000;
  static const int _mockTotalPayment = 3020800000;
  static const double _mockDsr = 33.7;
  static const double _mockPrincipalPercent = 66.2;
  static const double _mockInterestPercent = 33.8;

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
            onPressed: () {
              HistoryBottomSheet.show(context);
            },
          ),
          const SizedBox(width: AppSizes.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          children: [
            // ── Hero: Angsuran per Bulan ───────────────────────────────────
            _buildMonthlyPaymentCard(),
            const SizedBox(height: AppSizes.base),

            // ── Komposisi Angsuran ────────────────────────────────────────
            _buildCompositionCard(),
            const SizedBox(height: AppSizes.base),

            // ── DSR Status ────────────────────────────────────────────────
            _buildDsrCard(),
            const SizedBox(height: AppSizes.lg),

            // ── Hitung Ulang ──────────────────────────────────────────────
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

  Widget _buildMonthlyPaymentCard() {
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
            'Estimasi Angsuran per Bulan',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Rp ${_currencyFormat.format(_mockMonthlyPayment)}',
            style: AppTypography.displayNominal.copyWith(
              color: AppColors.white,
            ),
          ),
          Text(
            '/ bulan',
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionCard() {
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
          Text('Komposisi Angsuran', style: AppTypography.sectionHeader),
          const SizedBox(height: AppSizes.base),

          // Proportion bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    flex: (_mockPrincipalPercent * 10).round(),
                    child: Container(color: AppColors.primaryBlue),
                  ),
                  Expanded(
                    flex: (_mockInterestPercent * 10).round(),
                    child: Container(color: AppColors.primaryBlue.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Legend
          Row(
            children: [
              _buildLegendDot(AppColors.primaryBlue, 'Pokok ($_mockPrincipalPercent%)'),
              const SizedBox(width: AppSizes.base),
              _buildLegendDot(AppColors.primaryBlue.withValues(alpha: 0.35), 'Bunga ($_mockInterestPercent%)'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Breakdown
          _buildBreakdownRow('Total Pinjaman Pokok', _mockTotalLoan),
          _buildBreakdownRow('Total Estimasi Bunga', _mockTotalInterest),
          const Divider(height: AppSizes.lg),
          _buildBreakdownRow('Total Beban KPR', _mockTotalPayment, isBold: true),
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

  Widget _buildBreakdownRow(String label, int value, {bool isBold = false}) {
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
            'Rp ${_currencyFormat.format(value)}',
            style: isBold
                ? AppTypography.inputContent.copyWith(color: AppColors.primaryBlue)
                : AppTypography.inputContent,
          ),
        ],
      ),
    );
  }

  Widget _buildDsrCard() {
    final isIdeal = _mockDsr <= 40;
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
                    Text('Evaluasi Kapasitas Bayar (DSR)', style: AppTypography.sectionHeader),
                    const SizedBox(height: 2),
                    Text(
                      'Debt Service Ratio: ${_mockDsr.toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                type: isIdeal ? StatusType.murah : StatusType.mahal,
                label: isIdeal ? 'Ideal' : 'Berat',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Alias KprResultScreen agar kompatibel dengan penamaan lama.
typedef KprResultScreen = KprResultPage;
