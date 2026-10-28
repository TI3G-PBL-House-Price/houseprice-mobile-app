import '../../core/utils/currency_formatter.dart';

class InputValidator {
  static const double minHarga = 10000000.0;
  static const double minBunga = 0.1;
  static const double maxBunga = 30.0;
  static const int minTenor = 1;
  static const int maxTenor = 35;
  static const double minLuasTanah = 30.0;
  static const double minLuasBangunan = 1.0;

  static String? validateHarga(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga properti wajib diisi';
    }
    final nominal = CurrencyFormatter.parse(value);
    if (nominal <= 0) {
      return 'Harga properti harus lebih besar dari Rp 0';
    }
    if (nominal < minHarga) {
      return 'Harga properti minimal Rp ${CurrencyFormatter.format(minHarga)}';
    }
    return null;
  }

  static String? validateUangMuka(String? value, double hargaProperti) {
    if (value == null || value.trim().isEmpty) {
      return 'Uang muka (DP) wajib diisi';
    }
    final nominal = CurrencyFormatter.parse(value);
    if (nominal < 0) {
      return 'Uang muka tidak boleh bernilai negatif';
    }
    if (hargaProperti > 0 && nominal >= hargaProperti) {
      return 'Uang muka tidak boleh melebihi atau sama dengan harga properti';
    }
    return null;
  }

  static String? validateBunga(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Suku bunga wajib diisi';
    }
    final cleaned = value.replaceAll(',', '.').trim();
    final bunga = double.tryParse(cleaned);
    if (bunga == null) {
      return 'Format suku bunga tidak valid (gunakan angka)';
    }
    if (bunga < minBunga) {
      return 'Suku bunga minimal $minBunga%';
    }
    if (bunga > maxBunga) {
      return 'Suku bunga maksimal $maxBunga%';
    }
    return null;
  }

  static String? validateTenor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tenor wajib diisi';
    }
    final tenor = int.tryParse(value.trim());
    if (tenor == null) {
      return 'Tenor harus berupa bilangan bulat tahun';
    }
    if (tenor < minTenor) {
      return 'Tenor minimal $minTenor tahun';
    }
    if (tenor > maxTenor) {
      return 'Tenor maksimal $maxTenor tahun';
    }
    return null;
  }

  static String? validatePendapatan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pendapatan bulanan wajib diisi';
    }
    final nominal = CurrencyFormatter.parse(value);
    if (nominal <= 0) {
      return 'Pendapatan bulanan harus lebih besar dari Rp 0';
    }
    return null;
  }

  static String? validateHargaPenawaran(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga penawaran wajib diisi';
    }
    final nominal = CurrencyFormatter.parse(value);
    if (nominal <= 0) {
      return 'Harga penawaran harus lebih besar dari Rp 0';
    }
    return null;
  }

  static String? validateLuasTanah(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Luas tanah wajib diisi';
    }
    final luas = double.tryParse(value.trim());
    if (luas == null) {
      return 'Luas tanah harus berupa angka';
    }
    if (luas < minLuasTanah) {
      return 'Luas tanah minimal ${minLuasTanah.toInt()} m²';
    }
    return null;
  }

  static String? validateLuasBangunan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Luas bangunan wajib diisi';
    }
    final luas = double.tryParse(value.trim());
    if (luas == null) {
      return 'Luas bangunan harus berupa angka';
    }
    if (luas < minLuasBangunan) {
      return 'Luas bangunan minimal ${minLuasBangunan.toInt()} m²';
    }
    return null;
  }
}
