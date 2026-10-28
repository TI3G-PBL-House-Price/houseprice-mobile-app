import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

/// Bottom sheet daftar riwayat prediksi tersimpan lokal (FR-MOB-06).
/// Referensi: design-system.md § 5 – Akses Riwayat Lokal
class HistoryBottomSheet extends StatelessWidget {
  const HistoryBottomSheet({super.key});

  // ── Mock Data ──────────────────────────────────────────────────────────────
  static final _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static final List<Map<String, dynamic>> _mockHistory = [
    {
      'type': 'prediksi',
      'location': 'Jakarta Selatan - Kebayoran Baru',
      'result': 2650000000,
      'date': DateTime(2026, 10, 22, 14, 30),
    },
    {
      'type': 'kpr',
      'location': 'Simulasi KPR - 20 Tahun',
      'result': 8420000,
      'date': DateTime(2026, 10, 21, 10, 15),
    },
    {
      'type': 'prediksi',
      'location': 'Jakarta Pusat - Menteng',
      'result': 4100000000,
      'date': DateTime(2026, 10, 20, 9, 0),
    },
  ];

  /// Menampilkan bottom sheet riwayat.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HistoryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.70,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: AppSizes.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.base),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, color: AppColors.primaryBlue),
                const SizedBox(width: AppSizes.sm),
                Text('Riwayat Simulasi', style: AppTypography.sectionHeader),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Hapus semua riwayat
                  },
                  child: Text(
                    'Hapus Semua',
                    style: AppTypography.caption.copyWith(color: AppColors.alertRed),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // List
          Flexible(
            child: _mockHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.40)),
                          const SizedBox(height: AppSizes.md),
                          Text('Belum ada riwayat', style: AppTypography.bodyRegular),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.base,
                      vertical: AppSizes.sm,
                    ),
                    itemCount: _mockHistory.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),

                    itemBuilder: (_, index) => _buildHistoryTile(_mockHistory[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> item) {
    final isPrediction = item['type'] == 'prediksi';
    final result = item['result'] as int;
    final date = item['date'] as DateTime;

    String formattedResult;
    if (result >= 1000000000) {
      formattedResult = 'Rp ${(result / 1000000000).toStringAsFixed(2)} M';
    } else {
      formattedResult = 'Rp ${_currencyFormat.format(result)}';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: isPrediction ? AppColors.infoBlueBg : AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              isPrediction ? Icons.auto_awesome_rounded : Icons.account_balance_rounded,
              size: 20,
              color: isPrediction ? AppColors.primaryBlue : AppColors.successGreen,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['location'] as String,
                  style: AppTypography.inputContent.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedResult,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _dateFormat.format(date),
                style: AppTypography.captionSmall,
              ),
              const SizedBox(height: AppSizes.xs),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
            ],
          ),
        ],
      ),
    );
  }
}
