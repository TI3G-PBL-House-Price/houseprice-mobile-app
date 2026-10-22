import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

/// Layar Beranda Pasar Properti (FR-MOB-01).
/// Menampilkan ringkasan rata-rata harga, tren per kota, dan filter statistik.
/// Referensi: design-system.md § 5 – Tab 1 "Beranda"
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Mock Data ──────────────────────────────────────────────────────────────
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static const _mockAvgPrice = 2850000000; // Rp 2,85 M
  static const _mockAvgPricePerM2 = 18500000; // Rp 18,5 Jt / m²

  static const List<Map<String, dynamic>> _mockCityStats = [
    {'city': 'Jakarta Selatan', 'avg': 3200000000, 'change': 5.2},
    {'city': 'Jakarta Barat', 'avg': 2100000000, 'change': 3.8},
    {'city': 'Jakarta Timur', 'avg': 1800000000, 'change': -1.5},
    {'city': 'Jakarta Utara', 'avg': 2500000000, 'change': 2.1},
    {'city': 'Jakarta Pusat', 'avg': 4100000000, 'change': 4.6},
  ];

  String _formatBillions(int value) {
    final billions = value / 1000000000;
    if (billions >= 1) {
      return 'Rp ${billions.toStringAsFixed(2)} M';
    }
    final millions = value / 1000000;
    return 'Rp ${_currencyFormat.format(millions.round())} Jt';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.xs + 2),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(Icons.house_rounded, size: 20, color: AppColors.white),
            ),
            const SizedBox(width: AppSizes.sm),
            Text('HousePrice', style: AppTypography.sectionHeader),
          ],
        ),
        centerTitle: false,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card: Rata-Rata Harga DKI Jakarta ────────────────────
            _buildHeroCard(),
            const SizedBox(height: AppSizes.lg),

            // ── Section: Statistik Per Wilayah ────────────────────────────
            Text('Statistik Wilayah', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Rata-rata harga per kota administrasi',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.md),

            // ── Bar Chart Mockup ──────────────────────────────────────────
            _buildBarChart(),
            const SizedBox(height: AppSizes.lg),

            // ── Daftar Kota ───────────────────────────────────────────────
            ..._mockCityStats.map(_buildCityTile),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  /// Kartu hero besar menampilkan rata-rata harga DKI Jakarta.
  Widget _buildHeroCard() {
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
          Row(
            children: [
              Icon(Icons.location_city_rounded, size: 18, color: AppColors.white.withValues(alpha: 0.7)),
              const SizedBox(width: AppSizes.xs),
              Text(
                'DKI Jakarta',
                style: AppTypography.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Text(
            'Rata-Rata Harga Pasar',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            _formatBillions(_mockAvgPrice),
            style: AppTypography.displayNominal.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSizes.base),

          // Avg per m²
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
                  'Rp ${_currencyFormat.format(_mockAvgPricePerM2 ~/ 1000000)} Jt / m²',
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

  /// Diagram batang sederhana rata-rata harga per kota.
  Widget _buildBarChart() {
    final maxVal = _mockCityStats
        .map((s) => s['avg'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
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
        children: _mockCityStats.map((stat) {
          final fraction = (stat['avg'] as int) / maxVal;
          final cityName = (stat['city'] as String).replaceAll('Jakarta ', 'Jak. ');
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    cityName,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 14,
                      backgroundColor: AppColors.inputSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue.withValues(alpha: 0.15 + fraction * 0.85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Tile daftar kota dengan harga rata-rata dan persentase perubahan.
  Widget _buildCityTile(Map<String, dynamic> stat) {
    final change = stat['change'] as double;
    final isPositive = change >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // City icon
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.infoBlueBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.apartment_rounded, size: 22, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: AppSizes.md),

          // City name & avg
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat['city'] as String, style: AppTypography.inputContent),
                const SizedBox(height: 2),
                Text(
                  _formatBillions(stat['avg'] as int),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          // Change badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: isPositive ? AppColors.successGreenBg : AppColors.alertRedBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isPositive ? AppColors.successGreen : AppColors.alertRed,
                ),
                const SizedBox(width: 2),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: AppTypography.captionSmall.copyWith(
                    color: isPositive ? AppColors.successGreen : AppColors.alertRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
