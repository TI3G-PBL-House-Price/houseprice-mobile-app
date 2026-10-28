import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';

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
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.textInputAction,
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
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textInputAction: textInputAction,
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
