import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

  Future.delayed(const Duration(seconds: 3), () {
    if (!mounted) return;

    context.go('/home');
  });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF526579),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SvgPicture.asset(
              'assets/icons/home.svg',
              width: 150,
              height: 150,
              colorFilter: const ColorFilter.mode(
                    Color(0xFFF0F0F0),
                    BlendMode.srcIn,)
            ),

            const SizedBox(height: 20),

            const Text(
              'HousePrice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF)
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Prediksi Pasar Real Estate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}