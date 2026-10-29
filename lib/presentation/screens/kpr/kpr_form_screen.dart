import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_card.dart';

/// Layar Form Kalkulator KPR (FR-MOB-05).
/// Referensi: design-system.md § 3B – Struktur Kartu Form Kalkulator KPR
class KprFormScreen extends StatefulWidget {
  const KprFormScreen({super.key});

  @override
  State<KprFormScreen> createState() => _KprFormScreenState();
}

class _KprFormScreenState extends State<KprFormScreen> {
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
                  suffixText: 'Rp',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Uang Muka (DP)',
                  hint: 'Contoh: 500.000.000',
                  prefixIcon: Icons.savings_rounded,
                  suffixText: 'Rp',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Suku Bunga KPR per Tahun',
                  hint: 'Contoh: 7.5',
                  prefixIcon: Icons.percent_rounded,
                  suffixText: '% / thn',
                  helperText: 'Rata-rata suku bunga KPR bank: 7% – 12%',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Jangka Waktu Kredit (Tenor)',
                  hint: 'Contoh: 20',
                  prefixIcon: Icons.calendar_month_rounded,
                  suffixText: 'Tahun',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Pendapatan Bersih Bulanan',
                  hint: 'Contoh: 25.000.000',
                  prefixIcon: Icons.wallet_rounded,
                  suffixText: 'Rp',
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
                // TODO: Navigasi ke KPR Result
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
