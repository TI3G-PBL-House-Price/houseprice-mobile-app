import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';

/// Layanan pembacaan master wilayah (kota & kecamatan) dan statistik pasar dari backend Flask.
class MarketService {
  MarketService._();

  /// Cache master wilayah in-memory
  static List<String>? cachedCities;
  static Map<String, List<String>>? cachedDistrictMap;

  /// Mengambil data master wilayah dari backend (GET /api/v1/locations).
  /// Mengembalikan Map yang berisi list kota dan mapping kecamatan per kota.
  static Future<Map<String, dynamic>> fetchLocations() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.locationsUrl,
        requireAuth: false,
      );

      if (response is Map && response['status'] == 'success') {
        final data = response['data'] as List<dynamic>? ?? [];
        final List<String> cities = [];
        final Map<String, List<String>> districtMap = {};

        for (final item in data) {
          if (item is Map) {
            final city = item['city']?.toString() ?? '';
            final districtsRaw = item['districts'] as List<dynamic>? ?? [];
            final districts = districtsRaw.map((e) => e.toString()).toList();

            if (city.isNotEmpty) {
              cities.add(city);
              districtMap[city] = districts;
            }
          }
        }

        if (cities.isNotEmpty) {
          cachedCities = cities;
          cachedDistrictMap = districtMap;
          return {
            'cities': cities,
            'districtMap': districtMap,
          };
        }
      }
    } catch (_) {
      // Fallback ditangani pemanggil jika offline
    }

    return {
      'cities': cachedCities ?? defaultCities,
      'districtMap': cachedDistrictMap ?? defaultDistrictMap,
    };
  }

  /// Mengambil statistik agregasi harga properti per kota & kecamatan (GET /api/v1/market-statistics).
  static Future<List<Map<String, dynamic>>> fetchMarketStatistics({
    String? city,
    String? district,
  }) async {
    try {
      var url = ApiConstants.marketStatsUrl;
      final params = <String>[];
      if (city != null && city.isNotEmpty) params.add('city=${Uri.encodeComponent(city)}');
      if (district != null && district.isNotEmpty) params.add('district=${Uri.encodeComponent(district)}');
      if (params.isNotEmpty) {
        url = '$url?${params.join('&')}';
      }

      final response = await ApiClient.get(url, requireAuth: false);
      if (response is Map && response['status'] == 'success') {
        final list = response['data'] as List<dynamic>? ?? [];
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Fallback Master Wilayah DKI Jakarta ────────────────────────────────────
  static const List<String> defaultCities = [
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
    'Jakarta Pusat',
  ];

  static const Map<String, List<String>> defaultDistrictMap = {
    'Jakarta Selatan': [
      'Kebayoran Baru',
      'Cilandak',
      'Pesanggrahan',
      'Jagakarsa',
      'Pancoran',
      'Kebayoran Lama',
      'Mampang Prapatan',
      'Pasar Minggu',
      'Setia Budi',
      'Tebet',
    ],
    'Jakarta Barat': [
      'Kebon Jeruk',
      'Grogol Petamburan',
      'Cengkareng',
      'Kalideres',
      'Tambora',
      'Kembangan',
      'Palmerah',
      'Taman Sari',
    ],
    'Jakarta Timur': [
      'Matraman',
      'Jatinegara',
      'Duren Sawit',
      'Cakung',
      'Cipayung',
      'Ciracas',
      'Kramat Jati',
      'Makasar',
      'Pasar Rebo',
      'Pulo Gadung',
    ],
    'Jakarta Utara': [
      'Kelapa Gading',
      'Tanjung Priok',
      'Koja',
      'Penjaringan',
      'Pademangan',
      'Cilincing',
    ],
    'Jakarta Pusat': [
      'Menteng',
      'Tanah Abang',
      'Gambir',
      'Senen',
      'Cempaka Putih',
      'Johar Baru',
      'Kemayoran',
      'Sawah Besar',
    ],
  };
}
