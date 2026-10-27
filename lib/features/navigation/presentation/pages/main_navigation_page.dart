import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../routes.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../kpr/presentation/pages/kpr_form_page.dart';
import '../../../prediction/presentation/pages/predict_form_page.dart';

/// Scaffold pembungkus 3 tab BottomNavigationBar.
/// Referensi: design-system.md § 5 – Sistem Navigasi
///   1. Beranda (Publik)  2. Estimasi (Perlu Login)  3. Simulasi KPR (Perlu Login)
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    PredictFormPage(),
    KprFormPage(),
  ];

  void _onTabTapped(int index) {
    // Memeriksa autentikasi untuk tab Prediksi (1) dan KPR (2)
    if ((index == 1 || index == 2) && !AuthSession.isLoggedIn) {
      final featureName = index == 1 ? 'Prediksi Harga Rumah' : 'Kalkulator KPR';
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan masuk terlebih dahulu untuk mengakses fitur $featureName.',
          ),
          backgroundColor: AppColors.primaryNavy,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, AppRoutes.login).then((_) {
        if (mounted && AuthSession.isLoggedIn) {
          setState(() => _currentIndex = index);
        }
      });
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate_rounded),
              label: 'Estimasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance_rounded),
              label: 'KPR',
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias MainNavigation agar kompatibel dengan penamaan lama.
typedef MainNavigation = MainNavigationPage;
