import '../../../../core/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/session/auth_session.dart';
import 'prediction_result_data.dart';

/// Layanan integrasi inferensi Machine Learning & riwayat kalkulasi (Flask API).
class PredictionService {
  PredictionService._();

  /// Menjalankan inferensi model XGBoost v2 (dengan integrasi NJOP) melalui Flask backend.
  /// Endpoint: POST /api/v1/predict
  static Future<PredictionResultData> predictPrice({
    required String city,
    required String district,
    required double surfaceArea,
    required double buildingArea,
    required int bed,
    required int bath,
    required int carport,
  }) async {
    final payload = {
      'city': city.trim(),
      'district': district.trim(),
      'surface_area': surfaceArea,
      'building_area': buildingArea,
      'bed': bed,
      'bath': bath,
      'carport': carport,
    };

    final response = await ApiClient.post(
      ApiConstants.predictUrl,
      body: payload,
      requireAuth: true,
    );

    if (response is Map && response['status'] == 'success') {
      final data = response['data'] as Map<String, dynamic>? ?? {};
      return PredictionResultData.fromApiResponse(
        data: data,
        city: city,
        district: district,
        landArea: surfaceArea.round(),
        buildingArea: buildingArea.round(),
        bedrooms: bed,
        bathrooms: bath,
        garage: carport,
      );
    } else {
      final msg = response is Map ? response['message']?.toString() : null;
      throw ServerFailure(msg ?? 'Gagal memperoleh estimasi harga dari server');
    }
  }

  /// Mengambil daftar riwayat kalkulasi pengguna yang tersimpan di basis data backend.
  /// Endpoint: GET /api/v1/predict/history
  static Future<List<Map<String, dynamic>>> fetchPredictionHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    if (!AuthSession.isLoggedIn) {
      return [];
    }

    try {
      final url = '${ApiConstants.predictHistoryUrl}?limit=$limit&offset=$offset';
      final response = await ApiClient.get(url, requireAuth: true);

      if (response is Map && response['status'] == 'success') {
        final list = response['data'] as List<dynamic>? ?? [];
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Heuristik offline sebagai alternatif darurat jika backend tidak dapat dihubungi.
  static PredictionResultData offlineFallback({
    required String city,
    required String district,
    required double surfaceArea,
    required double buildingArea,
    required int bed,
    required int bath,
    required int carport,
  }) {
    const cityRates = {
      'Jakarta Pusat': 28000000.0,
      'Jakarta Selatan': 24500000.0,
      'Jakarta Utara': 21000000.0,
      'Jakarta Barat': 18500000.0,
      'Jakarta Timur': 14200000.0,
    };

    final baseRate = cityRates[city] ?? 20000000.0;
    final areaFactor = (surfaceArea * 0.55) + (buildingArea * 0.45);
    final facilityFactor = 1.0 + (bed * 0.04) + (bath * 0.03) + (carport * 0.02);
    final estPrice = (areaFactor * baseRate * facilityFactor).round();

    final lower = (estPrice * 0.90).round();
    final upper = (estPrice * 1.10).round();
    final avgPerM2 = buildingArea > 0 ? (estPrice / buildingArea).round() : 18500000;

    return PredictionResultData(
      city: city,
      district: district,
      landArea: surfaceArea.round(),
      buildingArea: buildingArea.round(),
      bedrooms: bed,
      bathrooms: bath,
      garage: carport,
      lowerBound: lower,
      upperBound: upper,
      avgPerM2: avgPerM2,
      predictedPrice: estPrice.toDouble(),
      modelVersion: 'v2.0.0 (Offline Mode)',
      algorithm: 'Statistik Heuristik Pasar',
      latencyMs: 15,
    );
  }
}
