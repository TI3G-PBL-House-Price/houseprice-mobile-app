import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../routes.dart';

/// Layar Sambutan & Beranda Publik / Landing Page.
/// Referensi: docs/docs/design-system.md § 3B – Landing Page (landing_screen.dart)
/// Dapat diakses publik tanpa login.
/// Membatasi akses fitur privat (Prediksi & KPR) dengan pengalihan ke Login jika belum terautentikasi.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const List<Map<String, dynamic>> _mockPublicCityStats = [
    {'city': 'Jakarta Selatan', 'avg': 'Rp 3,20 M', 'change': '+5.2%'},
    {'city': 'Jakarta Pusat', 'avg': 'Rp 4,10 M', 'change': '+4.6%'},
    {'city': 'Jakarta Barat', 'avg': 'Rp 2,10 M', 'change': '+3.8%'},
    {'city': 'Jakarta Utara', 'avg': 'Rp 2,50 M', 'change': '+2.1%'},
    {'city': 'Jakarta Timur', 'avg': 'Rp 1,80 M', 'change': '-1.5%'},
  ];

  void _accessFeature(BuildContext context, {required String featureName, required String route}) {
    if (!AuthSession.isLoggedIn) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan masuk terlebih dahulu untuk mengakses $featureName.',
          ),
          backgroundColor: AppColors.primaryNavy,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, AppRoutes.login);
    } else {
      Navigator.pushNamed(context, route);
    }
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
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.login_rounded, size: 18, color: AppColors.primaryBlue),
            label: Text(
              'Masuk',
              style: AppTypography.inputContent.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
          const SizedBox(width: AppSizes.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Ilustrasi & Sambutan Nilai Tambah ────────────────────
            _buildHeroBanner(),
            const SizedBox(height: AppSizes.xl),

            // ── Tombol Aksi Masuk & Daftar ─────────────────────────────────
            GradientButton(
              text: 'Masuk ke Akun',
              icon: Icons.login_rounded,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.base,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: Text(
                  'Daftar Akun Baru',
                  style: AppTypography.inputContent.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xxl),

            // ── Eksplorasi Fitur Aplikasi ──────────────────────────────────
            Text('Jelajahi Fitur Utama', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Akses fitur cerdas evaluasi properti & simulasi pembiayaan',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.md),

            // Kartu Fitur: Prediksi Harga Rumah (Terkunci / Perlu Login)
            _buildFeatureCard(
              context: context,
              icon: Icons.auto_awesome_rounded,
              title: 'Prediksi Harga Rumah',
              subtitle: 'Estimasi nilai pasar wajar berbasis Machine Learning dengan parameter lokasi & spesifikasi fisik.',
              isProtected: true,
              onTap: () => _accessFeature(
                context,
                featureName: 'Prediksi Harga Rumah',
                route: AppRoutes.predictForm,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Kartu Fitur: Kalkulator KPR (Terkunci / Perlu Login)
            _buildFeatureCard(
              context: context,
              icon: Icons.calculate_rounded,
              title: 'Kalkulator Simulasi KPR',
              subtitle: 'Simulasikan cicilan anuitas bulanan, komposisi pokok bunga, dan rasio kemampuan bayar (DSR).',
              isProtected: true,
              onTap: () => _accessFeature(
                context,
                featureName: 'Kalkulator KPR',
                route: AppRoutes.kprForm,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Kartu Fitur: Informasi Umum Pasar (Akses Publik / Terbuka)
            _buildFeatureCard(
              context: context,
              icon: Icons.trending_up_rounded,
              title: 'Tren & Statistik Pasar Properti',
              subtitle: 'Pantau pergerakan harga rata-rata properti hunian di 5 wilayah administrasi DKI Jakarta.',
              isProtected: false,
              onTap: () {
                // Navigasi ke info pasar publik
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda sedang melihat ringkasan pasar publik DKI Jakarta.'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.xxl),

            // ── Informasi Umum Pasar Terbuka (Publik) ───────────────────────
            Text('Pasar Properti DKI Jakarta', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Ringkasan data pasar yang dapat diakses publik tanpa login',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.md),

            Container(
              padding: const EdgeInsets.all(AppSizes.base),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _mockPublicCityStats.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            item['city'] as String,
                            style: AppTypography.bodyRegular.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          item['avg'] as String,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['change'] as String).startsWith('+')
                                ? AppColors.successGreenBg
                                : AppColors.alertRedBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['change'] as String,
                            style: AppTypography.captionSmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: (item['change'] as String).startsWith('+')
                                  ? AppColors.successGreen
                                  : AppColors.alertRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm + 2,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city_rounded, size: 14, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text(
                      'DKI Jakarta',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm + 2,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  'Akses Terbuka',
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          Text(
            'Solusi Cerdas Menilai Properti Idaman',
            style: AppTypography.headlineBold.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          Text(
            'Platform analisis nilai pasar properti berbasis Machine Learning dan simulasi pembiayaan KPR cerdas di DKI Jakarta.',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Mini Stat Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 16, color: AppColors.white),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Rata-Rata Pasar: Rp 2,85 M',
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

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isProtected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.base),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Fitur
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isProtected
                    ? AppColors.primaryNavy.withValues(alpha: 0.08)
                    : AppColors.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isProtected ? AppColors.primaryNavy : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppSizes.md),

            // Deskripsi Fitur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.sectionHeader.copyWith(fontSize: 15),
                        ),
                      ),
                      if (isProtected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.xs + 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.alertRedBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 11, color: AppColors.alertRed),
                              const SizedBox(width: 2),
                              Text(
                                'Perlu Login',
                                style: AppTypography.captionSmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.alertRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.xs + 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreenBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Publik',
                            style: AppTypography.captionSmall.copyWith(
                              fontSize: 10,
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.xs),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias LandingScreen agar konsisten dengan penamaan lama.
typedef LandingScreen = LandingPage;
