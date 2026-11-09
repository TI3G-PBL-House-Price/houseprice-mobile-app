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

  /// Nilai tengah rentang harga, dipakai untuk disimpan ke riwayat.
  int get midPrice => (lowerBound + upperBound) ~/ 2;

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
  );

  PredictionResultData copyWith({String? city, String? district}) {
    return PredictionResultData(
      city: city ?? this.city,
      district: district ?? this.district,
      landArea: landArea,
      buildingArea: buildingArea,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garage: garage,
      lowerBound: lowerBound,
      upperBound: upperBound,
      avgPerM2: avgPerM2,
    );
  }
}