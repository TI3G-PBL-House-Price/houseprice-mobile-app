/// Pengelola sesi autentikasi pengguna (Placeholder & Mock Session).
/// Menyediakan data dummy kredensial untuk keperluan testing sebelum
/// backend API token JWT diintegrasikan sepenuhnya.
class AuthSession {
  AuthSession._();

  /// Status autentikasi pengguna saat ini.
  static bool isLoggedIn = false;

  /// Informasi profil pengguna yang sedang login saat ini.
  static String? currentUserEmail;
  static String? currentUserName;

  /// Penyimpanan akun yang didaftarkan pengguna pada sesi lokal.
  static final Map<String, Map<String, String>> registeredAccounts = {};

  /// Alias mockAccounts untuk kompatibilitas.
  static Map<String, Map<String, String>> get mockAccounts => registeredAccounts;

  /// Memverifikasi kredensial akun terdaftar untuk login.
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

  /// Mengeluarkan sesi pengguna (logout).
  static void logout() {
    isLoggedIn = false;
    currentUserEmail = null;
    currentUserName = null;
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
