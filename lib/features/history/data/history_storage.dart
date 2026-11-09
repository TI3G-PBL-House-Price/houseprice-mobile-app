import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'history_record.dart';

/// Penyimpanan riwayat di perangkat (tanpa server) memakai shared_preferences.
/// Daftar di memori langsung berubah, penyimpanan ke perangkat menyusul.
class HistoryStorage {
  HistoryStorage._();

  static const String _key = 'history_records_v1';

  /// Data contoh yang tampil saat belum ada riwayat tersimpan.
  static List<HistoryRecord> _seed() => [
        HistoryRecord(
          type: 'prediksi',
          location: 'Jakarta Selatan - Kebayoran Baru',
          result: 2650000000,
          date: DateTime(2026, 10, 22, 14, 30),
        ),
        HistoryRecord(
          type: 'kpr',
          location: 'Simulasi KPR - 20 Tahun',
          result: 8420000,
          date: DateTime(2026, 10, 21, 10, 15),
        ),
        HistoryRecord(
          type: 'prediksi',
          location: 'Jakarta Pusat - Menteng',
          result: 4100000000,
          date: DateTime(2026, 10, 20, 9, 0),
        ),
      ];

  /// Daftar di memori, dibaca UI secara langsung.
  static final List<HistoryRecord> records = _seed();

  // Catatan baru yang ditambahkan sebelum data tersimpan selesai dimuat.
  static final List<HistoryRecord> _pending = [];
  static bool _loaded = false;
  static Future<void>? _loading;

  /// Memuat riwayat dari perangkat (hanya sekali).
  static Future<void> load() => _loading ??= _doLoad();

  static Future<void> _doLoad() async {
    List<HistoryRecord>? stored;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        stored = <HistoryRecord>[];
        for (final item in decoded) {
          try {
            stored.add(
              HistoryRecord.fromJson(Map<String, dynamic>.from(item as Map)),
            );
          } catch (_) {
            // Lewati catatan yang rusak.
          }
        }
      }
    } catch (_) {
      // Penyimpanan tidak tersedia: pakai data di memori, coba lagi nanti.
      _loading = null;
      return;
    }

    _loaded = true;
    if (stored != null) {
      records
        ..clear()
        ..addAll([..._pending, ...stored]);
    }
    if (_pending.isNotEmpty) {
      _pending.clear();
      await _persist();
    }
  }

  /// Menambah catatan baru di paling atas (langsung tampil), lalu menyimpannya.
  static void add(HistoryRecord record) {
    records.insert(0, record);
    if (_loaded) {
      _persist();
    } else {
      _pending.insert(0, record);
      load();
    }
  }

  /// Menghapus satu catatan.
  static void remove(HistoryRecord record) {
    records.remove(record);
    _pending.remove(record);
    if (_loaded) _persist();
  }

  /// Mengembalikan riwayat ke data contoh dan menghapus data tersimpan.
  static void reset() {
    records
      ..clear()
      ..addAll(_seed());
    _pending.clear();
    _clearStored();
  }

  static Future<void> _clearStored() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = records.map((e) => e.toJson()).toList();
      await prefs.setString(_key, jsonEncode(data));
    } catch (_) {
      // Gagal menyimpan: data tetap ada di memori selama aplikasi berjalan.
    }
  }
}
