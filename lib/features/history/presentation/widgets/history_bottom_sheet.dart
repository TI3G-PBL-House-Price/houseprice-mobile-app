import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../routes.dart';
import '../../data/history_record.dart';
import '../../data/history_storage.dart';

/// Bottom sheet daftar riwayat prediksi tersimpan lokal (FR-MOB-06).
/// Pengguna harus login terlebih dahulu untuk mengakses riwayat kalkulasi.
/// Data disimpan di perangkat lewat [HistoryStorage].
class HistoryBottomSheet extends StatefulWidget {
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

  /// Memuat riwayat dari penyimpanan lokal.
  static Future<void> load() => HistoryStorage.load();

  /// Menambahkan kalkulasi baru ke riwayat dan menyimpannya di perangkat.
  static void addRecord({
    required String type,
    required String location,
    required int result,
    DateTime? date,
  }) {
    HistoryStorage.add(
      HistoryRecord(
        type: type,
        location: location,
        result: result,
        date: date ?? DateTime.now(),
      ),
    );
  }

  /// Mengembalikan data riwayat ke kondisi awal (untuk testing).
  static void resetHistory() {
    HistoryStorage.reset();
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
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Muat data tersimpan di belakang layar, lalu segarkan daftar.
    HistoryStorage.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = HistoryStorage.records;

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
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),

          // Header
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
                        '${records.length} catatan tersimpan',
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

          // Daftar riwayat
          Flexible(
            child: records.isEmpty
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
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
                    itemBuilder: (_, index) {
                      final record = records[index];
                      return Dismissible(
                        key: ObjectKey(record),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSizes.base),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: AppColors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          setState(() => HistoryStorage.remove(record));
                        },
                        child: _buildHistoryTile(record),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(HistoryRecord item) {
    final isPrediction = item.isPrediction;

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
                  item.location,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  HistoryBottomSheet._formatDate(item.date),
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
                    ? 'Rp ${(item.result / 1000000000).toStringAsFixed(2)} M'
                    : 'Rp ${HistoryBottomSheet._currencyFormat.format(item.result)} / bln',
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
