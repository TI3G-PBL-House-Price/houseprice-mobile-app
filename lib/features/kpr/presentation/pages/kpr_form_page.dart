import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';
import 'kpr_result_page.dart';

/// Layar Form Kalkulator KPR (FR-MOB-05).
/// Referensi: design-system.md § 3B – Struktur Kartu Form Kalkulator KPR
class KprFormPage extends StatefulWidget {
  const KprFormPage({super.key});

  @override
  State<KprFormPage> createState() => _KprFormPageState();
}

class _KprFormPageState extends State<KprFormPage> {
  int _selectedPeriodTab = 0; // 0 = Bulanan, 1 = Tahunan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Simulasi KPR', style: AppTypography.sectionHeader),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Kalkulator KPR',
              style: AppTypography.headlineBold,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Simulasikan cicilan kredit pemilikan rumah dengan metode bunga anuitas',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Pemilih Periode (Bulanan / Tahunan) ────────────────────────
            _buildPeriodSelector(),
            const SizedBox(height: AppSizes.lg),

            // ── Input Finansial ────────────────────────────────────────────
            SectionCard(
              icon: Icons.account_balance_rounded,
              title: 'Data Finansial',
              badge: 'Rupiah',
              children: [
                const CustomTextField(
                  label: 'Nilai Properti / Harga Rumah',
                  hint: 'Contoh: 2.500.000.000',
                  prefixIcon: Icons.home_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Uang Muka / DP (Rupiah atau %)',
                  hint: 'Contoh: 500.000.000 (20%)',
                  prefixIcon: Icons.payments_rounded,
                  helperText: 'Standar minimum DP perbankan 10% – 20%',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Suku Bunga Tetap per Tahun (%)',
                  hint: 'Contoh: 6.5',
                  prefixIcon: Icons.percent_rounded,
                  suffixText: '% p.a.',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Tenor Pinjaman (Tahun)',
                  hint: 'Contoh: 20',
                  prefixIcon: Icons.calendar_today_rounded,
                  suffixText: 'Tahun',
                  helperText: 'Pilihan tenor umum: 10, 15, 20, 25 tahun',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            // ── Seksi 2: Profil Pendapatan ─────────────────────────────────
            SectionCard(
              icon: Icons.wallet_rounded,
              title: 'Profil Pendapatan & Beban',
              badge: 'Evaluasi DSR',
              children: [
                const CustomTextField(
                  label: 'Total Pendapatan Bersih Bulanan',
                  hint: 'Contoh: 25.000.000',
                  prefixIcon: Icons.attach_money_rounded,
                  helperText: 'Akumulasi gaji pemohon + pasangan jika joint income',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Total Cicilan Lain yang Sedang Berjalan',
                  hint: 'Contoh: 0',
                  prefixIcon: Icons.credit_card_rounded,
                  helperText: 'Cicilan kendaraan, kartu kredit, pinjaman lain',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            // ── Kotak Informasi DSR ────────────────────────────────────────
            _buildDsrInfoBox(),
            const SizedBox(height: AppSizes.lg),

            // ── Tombol CTA ─────────────────────────────────────────────────
            GradientButton(
              text: 'Hitung Simulasi KPR',
              icon: Icons.calculate_rounded,
              onPressed: () {
                HistoryBottomSheet.addRecord(
                  type: 'kpr',
                  location: 'Simulasi KPR - 20 Tahun',
                  result: 8420000,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KprResultPage(),
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

  /// Tab segmen atas: Bulanan vs Tahunan
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _buildPeriodTab('Bulanan', 0),
          _buildPeriodTab('Tahunan', 1),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isActive = _selectedPeriodTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriodTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.inputContent.copyWith(
                color: isActive ? AppColors.primaryBlue : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Info box rekomendasi DSR
  Widget _buildDsrInfoBox() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.infoBlueBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppSizes.iconMd,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Rasio Cicilan (DSR)',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Rekomendasi cicilan maksimal 30% – 40% dari total pendapatan bersih bulanan Anda.',
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.primaryBlue.withValues(alpha: 0.80),
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

/// Alias KprFormScreen agar kompatibel dengan penamaan lama.
typedef KprFormScreen = KprFormPage;
