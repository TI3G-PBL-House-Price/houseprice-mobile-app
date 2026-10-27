import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../routes.dart';

/// Bottom sheet daftar riwayat prediksi tersimpan lokal (FR-MOB-06).
/// Pengguna harus login terlebih dahulu untuk mengakses riwayat kalkulasi.
/// Referensi: design-system.md § 5 – Akses Riwayat Lokal
class HistoryBottomSheet extends StatelessWidget {
  const HistoryBottomSheet({super.key});

  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  static String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final month = months[date.month - 1];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} $month ${date.year}, $hour:$minute';
    }
  }

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

  /// Menambahkan kalkulasi baru ke riwayat secara otomatis.
  static void addRecord({
    required String type,
    required String location,
    required int result,
    DateTime? date,
  }) {
    _mockHistory.insert(0, {
      'type': type,
      'location': location,
      'result': result,
      'date': date ?? DateTime.now(),
    });
  }

  /// Mengembalikan data riwayat ke kondisi awal (untuk testing).
  static void resetHistory() {
    _mockHistory.clear();
    _mockHistory.addAll([
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
    ]);
  }

  /// Menampilkan bottom sheet riwayat dengan proteksi autentikasi.
  static void show(BuildContext context) {
    if (!AuthSession.isLoggedIn) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan masuk terlebih dahulu untuk melihat riwayat kalkulasi.',
          ),
          backgroundColor: AppColors.primaryNavy,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

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
          // ── Drag Handle ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: AppSizes.iconMd,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riwayat Kalkulasi', style: AppTypography.sectionHeader),
                      Text(
                        '${_mockHistory.length} catatan tersimpan',
                        style: AppTypography.captionSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: AppSizes.base),

          // ── Daftar Riwayat ───────────────────────────────────────────────
          Flexible(
            child: _mockHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 48,
                            color: AppColors.textHint.withValues(alpha: 0.50),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Belum ada riwayat',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Lakukan estimasi harga atau simulasi KPR untuk melihat riwayat',
                            textAlign: TextAlign.center,
                            style: AppTypography.captionSmall,
                          ),
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

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          // Ikon tipe
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: isPrediction
                  ? AppColors.primaryBlue.withValues(alpha: 0.10)
                  : AppColors.successGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              isPrediction ? Icons.home_rounded : Icons.account_balance_rounded,
              size: AppSizes.iconSm,
              color: isPrediction ? AppColors.primaryBlue : AppColors.successGreen,
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['location'] as String,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  _formatDate(item['date'] as DateTime),
                  style: AppTypography.captionSmall,
                ),
              ],
            ),
          ),

          // Nilai hasil
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isPrediction
                    ? 'Rp ${((item['result'] as int) / 1000000000).toStringAsFixed(2)} M'
                    : 'Rp ${_currencyFormat.format(item['result'])} / bln',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPrediction ? AppColors.primaryNavy : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPrediction ? AppColors.infoBlueBg : AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPrediction ? 'Estimasi' : 'KPR',
                  style: AppTypography.captionSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPrediction ? AppColors.primaryBlue : AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
