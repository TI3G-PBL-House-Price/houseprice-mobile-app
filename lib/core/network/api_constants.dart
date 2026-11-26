import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Konfigurasi URL dan Endpoint API Backend Flask (FR-MOB-02 / ML Model v2 NJOP Integration).
class ApiConstants {
  ApiConstants._();

  /// URL default backend server.
  /// - Android Emulator: http://10.0.2.2:5000 (merujuk ke localhost host machine)
  /// - iOS Simulator / Desktop (Windows/macOS/Linux) / Web: http://127.0.0.1:5000
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:5000';
  }

  /// Base URL aktif (dapat diubah saat runtime untuk pengujian device fisik / LAN)
  static String baseUrl = defaultBaseUrl;

  /// Timeout durasi permintaan HTTP (dalam detik)
  static const Duration timeoutDuration = Duration(seconds: 15);

  // ── Auth Endpoints ─────────────────────────────────────────────────────────
  static String get loginUrl => '$baseUrl/api/v1/auth/login';
  static String get registerUrl => '$baseUrl/api/v1/auth/register';
  static String get profileUrl => '$baseUrl/api/v1/auth/me';
  static String get logoutUrl => '$baseUrl/api/v1/auth/logout';

  // ── Market & Master Location Endpoints ─────────────────────────────────────
  static String get locationsUrl => '$baseUrl/api/v1/locations';
  static String get marketStatsUrl => '$baseUrl/api/v1/market-statistics';

  // ── Machine Learning Prediction Endpoints ──────────────────────────────────
  static String get predictUrl => '$baseUrl/api/v1/predict';
  static String get predictHistoryUrl => '$baseUrl/api/v1/predict/history';
  static String get healthCheckUrl => '$baseUrl/health';
}
