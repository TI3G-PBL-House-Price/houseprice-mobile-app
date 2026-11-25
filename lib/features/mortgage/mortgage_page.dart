
import 'package:flutter/material.dart';

class MortgagePage extends StatelessWidget {
  const MortgagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FF),
      appBar: AppBar(
        title: const Text('Kalkulator KPR'),
        backgroundColor: const Color(0xFFFFF8FF),
        foregroundColor: const Color(0xFF142B45),
      ),
      body: const Center(
        child: Text('Halaman Kalkulator KPR'),
      ),
    );
  }
}
