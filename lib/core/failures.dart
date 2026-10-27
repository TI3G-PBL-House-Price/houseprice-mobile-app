/// Definisi class kegagalan (Failure) umum dalam Clean Architecture.
/// Digunakan oleh layer domain dan data untuk menangani exception secara konsisten.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Kegagalan komunikasi dengan server atau endpoint backend API.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server']);
}

/// Kegagalan membaca atau menulis ke cache lokal / SQLite / SecureStorage.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Terjadi kesalahan pada cache penyimpanan']);
}

/// Kegagalan konektivitas jaringan atau sinyal internet.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi internet bermasalah']);
}

/// Kegagalan validasi input form (BVA / EP).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Kegagalan otentikasi (kredensial tidak valid, token kedaluwarsa, 401).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Autentikasi gagal']);
}
