import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';

/// Header visual modul autentikasi dengan icon brand dan headline teks.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.house_rounded,
              color: AppColors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Title
        Text(
          title,
          style: AppTypography.headlineBold,
        ),
        const SizedBox(height: AppSizes.xs),

        // Subtitle
        Text(
          subtitle,
          style: AppTypography.bodyRegular,
        ),
      ],
    );
  }
}
