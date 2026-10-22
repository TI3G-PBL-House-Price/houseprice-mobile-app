import 'package:flutter/material.dart';

/// Definisi kode hex palet warna resmi HousePrice.
/// Referensi: docs/docs/design-system.md § 1. Fondasi Token Warna
class AppColors {
  AppColors._();

  // ── Palet Warna Utama & Brand ──────────────────────────────────────────────

  /// Primary Dark Navy – kontainer gelap, kartu grafik, header, teks tombol
  static const Color primaryNavy = Color(0xFF0B192E);

  /// Primary Blue Accent – aksen interaktif, nominal estimasi, tab aktif
  static const Color primaryBlue = Color(0xFF0A58CA);

  /// Gradient Button Start (Navy pekat)
  static const Color gradientStart = Color(0xFF001D4A);

  /// Gradient Button End (Biru Royal)
  static const Color gradientEnd = Color(0xFF0A58CA);

  /// App Canvas Background – latar belakang layar utama
  static const Color background = Color(0xFFF4F7FA);

  /// Card Container – latar belakang kartu informasi
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Input Surface – latar belakang bidang isian teks, dropdown, stepper
  static const Color inputSurface = Color(0xFFEFF2F7);

  // ── Indikator Status & Semantik ────────────────────────────────────────────

  /// Murah / Nilai Baik / DSR Aman
  static const Color successGreen = Color(0xFF10B981);

  /// Background lencana hijau
  static const Color successGreenBg = Color(0xFFE6F7F0);

  /// Wajar / Sesuai Pasar
  static const Color infoBlue = Color(0xFF0A58CA);

  /// Background lencana biru
  static const Color infoBlueBg = Color(0xFFEBF3FF);

  /// Mahal / Di Atas Pasar / DSR Bahaya
  static const Color alertRed = Color(0xFFEF4444);

  /// Background lencana merah
  static const Color alertRedBg = Color(0xFFFEE2E2);

  // ── Teks ───────────────────────────────────────────────────────────────────

  /// Teks utama gelap
  static const Color textPrimary = Color(0xFF0B192E);

  /// Teks sekunder / deskripsi
  static const Color textSecondary = Color(0xFF64748B);

  /// Teks placeholder / hint
  static const Color textHint = Color(0xFF94A3B8);

  /// Warna putih murni
  static const Color white = Color(0xFFFFFFFF);

  // ── Gradasi tombol CTA ────────────────────────────────────────────────────

  /// Gradient utama untuk tombol Call-to-Action
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
