
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'price_data.dart';

class PriceChart extends StatefulWidget {
  const PriceChart({super.key});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  late Future<Map<String, double>> priceFuture;

  int? selectedIndex;

  static const regions = [
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Utara',
    'Jakarta Barat',
    'Jakarta Timur',
  ];

  static const labels = [
    'Pusat',
    'Selatan',
    'Utara',
    'Barat',
    'Timur',
  ];

  @override
  void initState() {
    super.initState();
    priceFuture = loadPrices();
  }

  Future<Map<String, double>> loadPrices() async {
    final data = await PriceDataService.loadData();

    return {
      for (final item in data)
        'Jakarta ${item.region}': item.medianPrice,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101A30),
        borderRadius: BorderRadius.circular(18),
      ),
      child: FutureBuilder<Map<String, double>>(
        future: priceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2176E8),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Gagal memuat data harga',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final prices = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Median Harga per Daerah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 10,
                    minY: 0,

                    // INTERACTION
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions) {
                          return;
                        }

                        final index =
                            response?.spot?.touchedBarGroupIndex;

                        if (index == null) return;

                        setState(() {
                          selectedIndex =
                              selectedIndex == index ? null : index;
                        });
                      },
                    ),

                    // BAR GROUPS
                    barGroups: List.generate(
                      regions.length,
                      (index) {
                        final price = prices[regions[index]] ?? 0;
                        final isSelected = selectedIndex == index;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: price,
                              width: 32,
                              color: isSelected
                                  ? const Color(0xFF2176E8)
                                  : const Color(0xFF424D65),
                              borderRadius:
                                  const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // GRID
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.08),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    borderData: FlBorderData(show: false),

                    // AXIS TITLES
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 ||
                                index >= labels.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Satuan: miliar rupiah',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
