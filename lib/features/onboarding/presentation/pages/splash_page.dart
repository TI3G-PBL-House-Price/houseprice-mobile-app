import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../routes.dart';

/// Layar Pembuka / Splash Screen.
/// Referensi: docs/docs/design-system.md § 3A – Splash & Onboarding Screen
/// Menampilkan logo HousePrice 120x120 dp terpusat vertikal dan indikator pemuatan Electric Blue.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Tengah Vertikal
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo HousePrice 120x120 dp
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.house_rounded,
                        size: 64,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Nama Aplikasi
                  Text(
                    'HousePrice',
                    style: AppTypography.displayNominal.copyWith(
                      color: AppColors.primaryNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),

                  // Tagline
                  Text(
                    'Solusi Cerdas Valuasi Properti',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Indikator Pemuatan di Bagian Bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizes.xxxl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Memuat sistem...',
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
