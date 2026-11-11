
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/../core/chart/price_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // HEADER
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF142B45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HousePrice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF142B45),
                            ),
                          ),
                          Text(
                            'Prediksi Pasar Real Estate',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF424D65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF142B45),
                    ),

                    const SizedBox(width: 16),

                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE8E5FA),
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: Color(0xFF142B45),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // PRICE CHART
                const PriceChart(),

                const SizedBox(height: 32),

                
                const Text(
                  'Apa yang bisa kami bantu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF142B45),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Pilih kalkulator instant berbasis kecerdasan data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF424D65),
                  ),
                ),

                const SizedBox(height: 20),

            
                _buildFeatureCard(
                  icon: 'assets/icons/CalculatorIcon.svg',
                  title: 'Hitung estimasi biaya',
                  description:
                      'Prediksi harga pasar dengan akurasi data ML berdasarkan luas tanah, bangunan, dan lokasi di Jakarta.',
                ),

                const SizedBox(height: 16),

            
                _buildFeatureCard(
                  icon: 'assets/icons/BanknotesIcon.svg',
                  title: 'Kalkulator KPR',
                  description:
                      'Simulasi cicilan bulanan, bunga fixed & floating, serta pilihan tenor terbaik yang sesuai anggaran Anda.',
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // REUSABLE FEATURE CARD
  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              Color(0xFF142B45),
              BlendMode.srcIn,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF142B45),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF424D65),
            ),
          ),
        ],
      ),
    );
  }
}
