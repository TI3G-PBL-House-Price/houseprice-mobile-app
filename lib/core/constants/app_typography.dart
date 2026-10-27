import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Konfigurasi TextStyle Plus Jakarta Sans.
/// Referensi: docs/docs/design-system.md § 2. Tipografi
/// Alias untuk AppFonts agar mendukung backward compatibility.
class AppTypography {
  AppTypography._();

  static TextStyle get displayNominal => AppFonts.displayNominal;
  static TextStyle get headlineBold => AppFonts.headlineBold;
  static TextStyle get sectionHeader => AppFonts.sectionHeader;
  static TextStyle get inputContent => AppFonts.inputContent;
  static TextStyle get bodyRegular => AppFonts.bodyRegular;
  static TextStyle get bodySmall => AppFonts.bodySmall;
  static TextStyle get caption => AppFonts.caption;
  static TextStyle get captionSmall => AppFonts.captionSmall;
}
