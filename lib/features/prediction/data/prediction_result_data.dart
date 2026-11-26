/// Data hasil prediksi yang dikirim ke ResultPage.
class PredictionResultData {
  const PredictionResultData({
    required this.city,
    required this.district,
    required this.landArea,
    required this.buildingArea,
    required this.bedrooms,
    required this.bathrooms,
    required this.garage,
    required this.lowerBound,
    required this.upperBound,
    required this.avgPerM2,
    this.predictionId,
    this.predictedPrice,
    this.modelVersion,
    this.algorithm,
    this.latencyMs,
  });

  final String city;
  final String district;
  final int landArea;
  final int buildingArea;
  final int bedrooms;
  final int bathrooms;
  final int garage;
  final int lowerBound;
  final int upperBound;
  final int avgPerM2;

  // Metadata inferensi dari backend Flask (ML Model v2)
  final String? predictionId;
  final double? predictedPrice;
  final String? modelVersion;
  final String? algorithm;
  final int? latencyMs;

  /// Nilai tengah rentang harga, dipakai untuk disimpan ke riwayat.
  int get midPrice => (predictedPrice != null && predictedPrice! > 0)
      ? predictedPrice!.round()
      : (lowerBound + upperBound) ~/ 2;

  /// Data contoh (mock) sampai hasil prediksi ML tersambung.
  static const PredictionResultData sample = PredictionResultData(
    city: 'Jakarta Selatan',
    district: 'Kebayoran Baru',
    landArea: 140,
    buildingArea: 120,
    bedrooms: 3,
    bathrooms: 2,
    garage: 1,
    lowerBound: 2450000000,
    upperBound: 2800000000,
    avgPerM2: 18500000,
    modelVersion: 'v2.0.0',
    algorithm: 'XGBoost Regressor (Tuned)',
    latencyMs: 124,
  );

  /// Factory untuk memetakan payload respon REST API Flask POST /api/v1/predict.
  factory PredictionResultData.fromApiResponse({
    required Map<String, dynamic> data,
    required String city,
    required String district,
    required int landArea,
    required int buildingArea,
    required int bedrooms,
    required int bathrooms,
    required int garage,
  }) {
    final predPrice = (data['predicted_price'] as num?)?.toDouble() ?? 0.0;
    final tolerance = data['tolerance_range'] as Map<String, dynamic>? ?? {};
    final lower = (tolerance['lower_bound'] as num?)?.round() ?? (predPrice * 0.9).round();
    final upper = (tolerance['upper_bound'] as num?)?.round() ?? (predPrice * 1.1).round();

    final modelInfo = data['model_info'] as Map<String, dynamic>? ?? {};
    final performance = data['performance'] as Map<String, dynamic>? ?? {};

    final calculatedAvgPerM2 = buildingArea > 0
        ? (predPrice / buildingArea).round()
        : (landArea > 0 ? (predPrice / landArea).round() : 18500000);

    return PredictionResultData(
      city: city,
      district: district,
      landArea: landArea,
      buildingArea: buildingArea,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garage: garage,
      lowerBound: lower,
      upperBound: upper,
      avgPerM2: calculatedAvgPerM2,
      predictionId: data['prediction_id']?.toString(),
      predictedPrice: predPrice,
      modelVersion: modelInfo['version']?.toString() ?? 'v2.0.0',
      algorithm: modelInfo['algorithm']?.toString() ?? 'XGBoost Regressor (Tuned)',
      latencyMs: (performance['latency_ms'] as num?)?.toInt(),
    );
  }

  PredictionResultData copyWith({
    String? city,
    String? district,
    int? landArea,
    int? buildingArea,
    int? bedrooms,
    int? bathrooms,
    int? garage,
    int? lowerBound,
    int? upperBound,
    int? avgPerM2,
    String? predictionId,
    double? predictedPrice,
    String? modelVersion,
    String? algorithm,
    int? latencyMs,
  }) {
    return PredictionResultData(
      city: city ?? this.city,
      district: district ?? this.district,
      landArea: landArea ?? this.landArea,
      buildingArea: buildingArea ?? this.buildingArea,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      garage: garage ?? this.garage,
      lowerBound: lowerBound ?? this.lowerBound,
      upperBound: upperBound ?? this.upperBound,
      avgPerM2: avgPerM2 ?? this.avgPerM2,
      predictionId: predictionId ?? this.predictionId,
      predictedPrice: predictedPrice ?? this.predictedPrice,
      modelVersion: modelVersion ?? this.modelVersion,
      algorithm: algorithm ?? this.algorithm,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}
