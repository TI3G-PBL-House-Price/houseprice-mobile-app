import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../routes.dart';

/// Halaman Carousel Get Started / Onboarding.
/// Referensi: docs/docs/design-system.md § 3A – Onboarding Carousel Screen
/// 3 Slide interaktif dengan ilustrasi proporsi 45%, dot indicators dinamis,
/// tombol Lewati (Skip), Lanjut (Next), dan Mulai Sekarang (Get Started).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.auto_awesome_rounded,
      'badge': 'Machine Learning',
      'title': 'Estimasi Harga Properti Akurat',
      'description':
          'Kalkulasi taksiran harga pasar wajar rumah di DKI Jakarta secara instan didukung model Machine Learning mutakhir.',
    },
    {
      'icon': Icons.account_balance_rounded,
      'badge': 'Metode Anuitas',
      'title': 'Simulasi KPR Transparan',
      'description':
          'Hitung estimasi angsuran bulanan dengan metode bunga anuitas perbankan serta evaluasi rasio kapasitas bayar (DSR).',
    },
    {
      'icon': Icons.price_check_rounded,
      'badge': 'Cek Nilai Pasar',
      'title': 'Evaluasi Kewajaran Pasar',
      'description':
          'Bandingkan harga penawaran penjual terhadap nilai pasar wajar untuk keputusan investasi properti yang lebih aman.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.landing);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Lewati',
              style: AppTypography.inputContent.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PageView Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // Bagian Bawah: Dot Indicators & Tombol Aksi
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                children: [
                  // Dot Indicators (24x8 dp aktif, 8x8 dp tidak aktif)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Tombol Navigasi Bawah
                  if (isLastPage)
                    GradientButton(
                      text: 'Mulai Sekarang',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: _finishOnboarding,
                    )
                  else
                    Row(
                      children: [
                        // Tombol Sebelumnya (jika bukan slide 0)
                        if (_currentPage > 0) ...[
                          OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryNavy,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.lg,
                                vertical: AppSizes.base,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 20),
                          ),
                          const SizedBox(width: AppSizes.md),
                        ],

                        // Tombol Next (Lanjut)
                        Expanded(
                          child: GradientButton(
                            text: 'Lanjut',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _nextPage,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    final mediaQuery = MediaQuery.of(context);
    final illustrationHeight = mediaQuery.size.height * 0.40;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi Visual (Proporsi ~40-45% tinggi layar)
          SizedBox(
            height: illustrationHeight,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Latar Belakang Lingkaran Halus
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    ),
                  ),

                  // Kartu Utama Ilustrasi
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        slide['icon'] as IconData,
                        size: 56,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Badge Seksi
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.infoBlueBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              slide['badge'] as String,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Teks Headline (22sp Bold terpusat)
          Text(
            slide['title'] as String,
            textAlign: TextAlign.center,
            style: AppTypography.headlineBold.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Teks Body (14sp Regular terpusat)
          Text(
            slide['description'] as String,
            textAlign: TextAlign.center,
            style: AppTypography.bodyRegular.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
