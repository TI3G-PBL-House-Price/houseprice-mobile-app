/// Satu catatan riwayat (estimasi harga atau simulasi KPR).
class HistoryRecord {
  const HistoryRecord({
    required this.type,
    required this.location,
    required this.result,
    required this.date,
  });

  /// 'prediksi' atau 'kpr'
  final String type;
  final String location;
  final int result;
  final DateTime date;

  bool get isPrediction => type == 'prediksi';

  Map<String, dynamic> toJson() => {
        'type': type,
        'location': location,
        'result': result,
        'date': date.toIso8601String(),
      };

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      type: json['type'] as String,
      location: json['location'] as String,
      result: (json['result'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}