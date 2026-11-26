import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../failures.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

/// Pengelola sesi autentikasi pengguna (JWT Token & Sinkronisasi Backend Flask).
/// Mendukung persistensi sesi dengan SharedPreferences serta fallback mock
/// untuk keperluan unit/widget testing tanpa server backend aktif.
class AuthSession {
  AuthSession._();

  static const String _prefTokenKey = 'auth_token_jwt';
  static const String _prefEmailKey = 'auth_user_email';
  static const String _prefNameKey = 'auth_user_name';
  static const String _prefUserIdKey = 'auth_user_id';

  /// Token JWT Bearer dari Flask backend.
  static String? token;

  /// ID Pengguna di basis data PostgreSQL backend.
  static String? currentUserId;

  /// Status autentikasi pengguna saat ini.
  static bool isLoggedIn = false;

  /// Informasi profil pengguna yang sedang login saat ini.
  static String? currentUserEmail;
  static String? currentUserName;
  static String? currentUserPhone;

  /// Penyimpanan akun yang didaftarkan pengguna pada sesi lokal / offline.
  static final Map<String, Map<String, String>> registeredAccounts = {};

  /// Alias mockAccounts untuk kompatibilitas.
  static Map<String, Map<String, String>> get mockAccounts => registeredAccounts;

  /// Mendeteksi apakah aplikasi sedang berjalan di lingkungan pengujian (flutter test).
  static bool get isTestMode {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Inisialisasi awal membaca sesi tersimpan di SharedPreferences (saat startup).
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_prefTokenKey);
      final savedEmail = prefs.getString(_prefEmailKey);
      final savedName = prefs.getString(_prefNameKey);
      final savedUserId = prefs.getString(_prefUserIdKey);

      if (savedToken != null && savedToken.isNotEmpty) {
        token = savedToken;
        currentUserEmail = savedEmail;
        currentUserName = savedName;
        currentUserId = savedUserId;
        isLoggedIn = true;
      }
    } catch (_) {}
  }

  /// Menyimpan sesi JWT ke SharedPreferences perangkat.
  static Future<void> _persistSession({
    required String jwtToken,
    required String email,
    required String name,
    String? userId,
  }) async {
    token = jwtToken;
    currentUserEmail = email;
    currentUserName = name;
    currentUserId = userId;
    isLoggedIn = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefTokenKey, jwtToken);
      await prefs.setString(_prefEmailKey, email);
      await prefs.setString(_prefNameKey, name);
      if (userId != null) {
        await prefs.setString(_prefUserIdKey, userId);
      }
    } catch (_) {}
  }

  /// Login asinkron terintegrasi dengan REST API Flask Backend.
  /// Otomatis menyimpan Bearer JWT Token dan data profil pengguna.
  static Future<String?> loginWithBackend(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      final response = await ApiClient.post(
        ApiConstants.loginUrl,
        body: {
          'email': cleanEmail,
          'password': password,
        },
        requireAuth: false,
      );

      if (response is Map && response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final jwtToken = data['access_token'] as String? ?? '';
        final userObj = data['user'] as Map<String, dynamic>? ?? {};

        final name = userObj['full_name'] as String? ?? cleanEmail.split('@').first;
        final userId = userObj['id'] as String?;
        currentUserPhone = userObj['phone_number'] as String?;

        await _persistSession(
          jwtToken: jwtToken,
          email: cleanEmail,
          name: name,
          userId: userId,
        );

        // Rekam juga ke registeredAccounts lokal agar sinkron
        registeredAccounts[cleanEmail] = {
          'name': name,
          'password': password,
        };

        return null; // Berhasil tanpa error
      } else {
        return response['message']?.toString() ?? 'Gagal masuk akun';
      }
    } on AuthFailure catch (e) {
      return e.message;
    } on ValidationFailure catch (e) {
      return e.message;
    } on Failure catch (e) {
      // Jika jaringan/server offline, fallback ke verifikasi lokal jika terdaftar
      if (registeredAccounts.containsKey(cleanEmail)) {
        return login(cleanEmail, password);
      }
      return '${e.message}. Pastikan backend Flask sudah aktif di ${ApiConstants.baseUrl}';
    } catch (e) {
      if (registeredAccounts.containsKey(cleanEmail)) {
        return login(cleanEmail, password);
      }
      return 'Gagal terhubung ke backend: $e';
    }
  }

  /// Registrasi akun asinkron terintegrasi dengan REST API Flask Backend.
  static Future<String?> registerWithBackend({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      final response = await ApiClient.post(
        ApiConstants.registerUrl,
        body: {
          'full_name': name.trim(),
          'email': cleanEmail,
          'password': password,
          'confirm_password': confirmPassword,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber.trim(),
        },
        requireAuth: false,
      );

      if (response is Map && (response['status'] == 'success' || response['data'] != null)) {
        // Catat akun juga ke memori lokal
        register(name: name, email: cleanEmail, password: password);
        return null;
      } else {
        return response['message']?.toString() ?? 'Pendaftaran akun gagal';
      }
    } on Failure catch (e) {
      // Jika backend tidak aktif / offline, simpan ke lokal dengan pesan peringatan
      register(name: name, email: cleanEmail, password: password);
      return '${e.message} (Akun disimpan sementara secara offline)';
    } catch (e) {
      register(name: name, email: cleanEmail, password: password);
      return 'Koneksi backend gagal: $e (Akun disimpan sementara secara offline)';
    }
  }

  /// Memverifikasi kredensial akun terdaftar untuk login (Sinkron / Mock).
  /// Mengembalikan pesan kesalahan jika gagal, atau null jika berhasil.
  static String? login(String email, String password) {
    final cleanEmail = email.toLowerCase().trim();
    final account = registeredAccounts[cleanEmail];
    if (account == null) {
      return 'Email belum terdaftar. Silakan daftar akun baru terlebih dahulu.';
    }
    if (account['password'] != password) {
      return 'Kata sandi yang Anda masukkan salah.';
    }
    isLoggedIn = true;
    currentUserEmail = cleanEmail;
    currentUserName = account['name'];
    token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    return null;
  }

  /// Mendaftarkan akun baru ke dalam sesi memori lokal.
  static void register({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanEmail = email.toLowerCase().trim();
    registeredAccounts[cleanEmail] = {
      'name': name.trim(),
      'password': password,
    };
  }

  /// Mengeluarkan sesi pengguna (logout) dan menghapus token JWT.
  static Future<void> logout() async {
    if (token != null && !token!.startsWith('mock_')) {
      try {
        await ApiClient.post(ApiConstants.logoutUrl, requireAuth: true);
      } catch (_) {}
    }

    isLoggedIn = false;
    currentUserEmail = null;
    currentUserName = null;
    currentUserPhone = null;
    currentUserId = null;
    token = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefEmailKey);
      await prefs.remove(_prefNameKey);
      await prefs.remove(_prefUserIdKey);
    } catch (_) {}
  }

  /// Memeriksa apakah fitur/rute memerlukan login.
  static bool requiresAuth(String routeName) {
    const protectedRoutes = [
      '/predict-form',
      '/predict-result',
      '/kpr-form',
      '/kpr-result',
    ];
    return protectedRoutes.contains(routeName);
  }
}
