import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Konfigurasi TextStyle Plus Jakarta Sans.
/// Referensi: docs/docs/design-system.md § 2. Tipografi
class AppTypography {
  AppTypography._();

  /// Display Nominal – 30sp / ExtraBold (w800)
  /// Digunakan untuk angka cicilan, harga besar.
  static TextStyle displayNominal = GoogleFonts.plusJakartaSans(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  /// Headline Bold – 22sp / Bold (w700)
  /// Digunakan untuk judul halaman.
  static TextStyle headlineBold = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section Header – 16sp / Bold (w700)
  /// Digunakan untuk judul kartu seksi form.
  static TextStyle sectionHeader = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Input Content – 15sp / SemiBold (w600)
  /// Digunakan untuk nilai di dalam input & dropdown.
  static TextStyle inputContent = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body Regular – 14sp / Regular (w400)
  /// Digunakan untuk sub-heading & deskripsi kartu.
  static TextStyle bodyRegular = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Body Small – 13sp / Regular (w400)
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption & Units – 12sp / Medium (w500)
  /// Digunakan untuk penanda satuan, lencana, disclaimer.
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  /// Caption kecil – 11sp / Medium (w500)
  static TextStyle captionSmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );
}
