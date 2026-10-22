import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';

/// Form field rounded abu-abu dengan prefix icon.
/// Referensi: design-system.md § 3 – Form & Penataan Kartu
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.helperText,
    this.keyboardType,
    this.controller,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: AppSizes.xs),

        // Field
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.inputContent,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: AppSizes.iconMd, color: AppColors.textHint)
                : null,
            suffixText: suffixText,
            suffixStyle: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Helper text
        if (helperText != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            helperText!,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}
