import 'package:flutter/services.dart';
import 'dart:convert';

class PriceData {
  final String region;
  final double medianPrice;

  const PriceData({
    required this.region,
    required this.medianPrice,
  });
}

class PriceDataService {
  static Future<List<PriceData>> loadData() async {
    final raw = await rootBundle.loadString(
      'assets/data/jakarta_house_imputed.csv',
    );

    final lines = const LineSplitter().convert(raw);
    final headers = lines.first.split(',');

    final priceIndex = headers.indexOf('price');
    final cityIndex = headers.indexOf('city');

    final prices = <String, List<double>>{};

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;

      final columns = line.split(',');

      final city = columns[cityIndex].trim();
      final price = double.tryParse(columns[priceIndex].trim());

      if (price == null) continue;

      prices.putIfAbsent(city, () => []);
      prices[city]!.add(price);
    }

    final cityOrder = [
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Utara',
      'Jakarta Barat',
      'Jakarta Timur',
    ];

    return cityOrder.map((city) {
      final values = prices[city] ?? [];
      values.sort();

      final middle = values.length ~/ 2;

      final median = values.isEmpty
          ? 0.0
          : values.length.isOdd
              ? values[middle]
              : (values[middle - 1] + values[middle]) / 2;

      return PriceData(
        region: city.replaceFirst('Jakarta ', ''),
        medianPrice: median / 1000000000,
      );
    }).toList();
  }
}