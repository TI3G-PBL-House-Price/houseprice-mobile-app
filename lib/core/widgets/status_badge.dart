import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';

/// Tipe status evaluasi harga / KPR.
enum StatusType { murah, wajar, mahal }

/// Lencana pil status (Murah / Wajar / Mahal).
/// Referensi: design-system.md § 1B – Indikator Status & Semantik
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.type,
    required this.label,
  });

  final StatusType type;
  final String label;

  Color get _backgroundColor {
    switch (type) {
      case StatusType.murah:
        return AppColors.successGreenBg;
      case StatusType.wajar:
        return AppColors.infoBlueBg;
      case StatusType.mahal:
        return AppColors.alertRedBg;
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusType.murah:
        return AppColors.successGreen;
      case StatusType.wajar:
        return AppColors.infoBlue;
      case StatusType.mahal:
        return AppColors.alertRed;
    }
  }

  IconData get _icon {
    switch (type) {
      case StatusType.murah:
        return Icons.trending_down_rounded;
      case StatusType.wajar:
        return Icons.check_circle_outline_rounded;
      case StatusType.mahal:
        return Icons.trending_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: AppSizes.iconSm, color: _textColor),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
