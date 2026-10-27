import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Definisi konstanta font & TextStyle aplikasi HousePrice.
/// Mengacu pada dokumen design-system.md § 2. Tipografi (Plus Jakarta Sans).
class AppFonts {
  AppFonts._();

  /// Nama family font resmi aplikasi
  static const String fontFamily = 'Plus Jakarta Sans';

  /// Display Nominal – 30sp / ExtraBold (w800)
  /// Digunakan untuk angka cicilan per bulan dan nominal hasil prediksi.
  static TextStyle displayNominal = GoogleFonts.plusJakartaSans(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  /// Headline Bold – 22sp / Bold (w700)
  /// Digunakan untuk judul layar utama ("Selamat Datang", "Estimasi Biaya Properti", dll).
  static TextStyle headlineBold = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Section Header – 16sp / Bold (w700)
  /// Digunakan untuk judul seksi form ("Wilayah & Lokasi", "Informasi Akun").
  static TextStyle sectionHeader = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Input Content – 15sp / SemiBold (w600)
  /// Digunakan untuk teks di dalam input box, dropdown, dan form auth.
  static TextStyle inputContent = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body Regular – 14sp / Regular (w400)
  /// Digunakan untuk deskripsi umum, penjelasan onboarding, dan subteks.
  static TextStyle bodyRegular = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Body Small – 13sp / Regular (w400)
  /// Digunakan untuk paragraf sekunder kartu dan info panduan.
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption & Units – 12sp / Medium (w500)
  /// Digunakan untuk penanda satuan (m², Tahun), lencana pil status, dan teks disclaimer.
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  /// Caption kecil – 11sp / Medium (w500)
  /// Digunakan untuk stempel waktu, penanda unit kecil, dan subtext validasi.
  static TextStyle captionSmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );
}
