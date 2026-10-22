import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/status_badge.dart';

/// Layar Hasil Estimasi & Cek Kewajaran (FR-MOB-03 & FR-MOB-04).
/// Referensi: design-system.md § 4A – Layar Hasil Estimasi
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  // ── Mock Data ──────────────────────────────────────────────────────────────
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static const _mockLowerBound = 2450000000;
  static const _mockUpperBound = 2800000000;
  static const _mockAvgPerM2 = 18500000;

  // Mock spesifikasi properti
  static const _mockSpec = {
    'Kota': 'Jakarta Selatan',
    'Kecamatan': 'Kebayoran Baru',
    'Luas Tanah': '140 m²',
    'Luas Bangunan': '120 m²',
    'Kamar Tidur': '3',
    'Kamar Mandi': '2',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Valuasi Properti', style: AppTypography.sectionHeader),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Riwayat',
            onPressed: () {
              // TODO: Buka HistoryBottomSheet
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          children: [
            // ── CARD 1: Estimasi Nilai Pasar ──────────────────────────────
            _buildEstimationCard(),
            const SizedBox(height: AppSizes.base),

            // ── CARD 2: Cek Kewajaran Harga ──────────────────────────────
            _buildFairnessCard(),
            const SizedBox(height: AppSizes.base),

            // ── CARD 3: Ringkasan Spesifikasi ────────────────────────────
            _buildSpecCard(),
            const SizedBox(height: AppSizes.lg),

            // ── Action Buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Hitung Ulang'),
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
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                    label: const Text('Simpan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Simpan ke SQLite
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            GradientButton(
              text: 'Bagikan Estimasi Nilai',
              icon: Icons.share_rounded,
              onPressed: () {
                // TODO: Share hasil
              },
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  /// CARD 1: Estimasi Nilai Pasar
  Widget _buildEstimationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rentang Harga Pasar Wajar',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_currencyFormat.format(_mockLowerBound ~/ 1000000)} Jt',
                style: AppTypography.headlineBold.copyWith(color: AppColors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Text(
                  'sampai',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(
                'Rp ${_currencyFormat.format(_mockUpperBound ~/ 1000000)} Jt',
                style: AppTypography.headlineBold.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.base),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.straighten_rounded, size: 16, color: AppColors.white.withValues(alpha: 0.7)),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Rata-rata: Rp ${_currencyFormat.format(_mockAvgPerM2 ~/ 1000000)} Jt / m²',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CARD 2: Cek Kewajaran Harga Penawaran
  Widget _buildFairnessCard() {
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.price_check_rounded, size: 22, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text('Cek Kewajaran Harga', style: AppTypography.sectionHeader),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Masukkan harga penawaran penjual untuk evaluasi',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSizes.md),

          // Input harga penawaran
          TextField(
            style: AppTypography.inputContent,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 2.500.000.000',
              prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.textHint),
              prefixText: 'Rp  ',
              prefixStyle: AppTypography.inputContent.copyWith(color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Tombol evaluasi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.assessment_rounded, size: 18),
              label: const Text('Evaluasi Kewajaran'),
              onPressed: () {
                // TODO: Hitung deviasi
              },
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Status badge (mock: Wajar)
          const Center(
            child: StatusBadge(
              type: StatusType.wajar,
              label: 'Wajar / Sesuai Pasar (Deviasi 2%)',
            ),
          ),
        ],
      ),
    );
  }

  /// CARD 3: Ringkasan Spesifikasi Properti
  Widget _buildSpecCard() {
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.description_rounded, size: 22, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSizes.md),
              Text('Ringkasan Spesifikasi', style: AppTypography.sectionHeader),
            ],
          ),
          const SizedBox(height: AppSizes.base),

          // Grid spesifikasi
          ..._buildSpecRows(),
        ],
      ),
    );
  }

  List<Widget> _buildSpecRows() {
    final entries = _mockSpec.entries.toList();
    final List<Widget> rows = [];

    for (var i = 0; i < entries.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: Row(
          children: [
            Expanded(child: _buildSpecItem(entries[i].key, entries[i].value)),
            if (i + 1 < entries.length)
              Expanded(child: _buildSpecItem(entries[i + 1].key, entries[i + 1].value)),
          ],
        ),
      ));
    }
    return rows;
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.inputContent),
      ],
    );
  }
}
