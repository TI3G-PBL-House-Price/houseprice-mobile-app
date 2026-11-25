
import 'package:flutter/material.dart';

class EstimationPage extends StatelessWidget {
  const EstimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),
      appBar: AppBar(
        title: const Text('Estimasi Harga'),
        backgroundColor: const Color(0xFFFFF8FF),
        foregroundColor: const Color(0xFF142B45),
      ),
      body: const Center(
        child: Text('Halaman Estimasi Harga'),
      ),
    );
  }
}
