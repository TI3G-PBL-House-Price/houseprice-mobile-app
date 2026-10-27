import 'package:flutter/material.dart';

import 'core/session/auth_session.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/kpr/presentation/pages/kpr_form_page.dart';
import 'features/kpr/presentation/pages/kpr_result_page.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/prediction/presentation/pages/predict_form_page.dart';
import 'features/prediction/presentation/pages/result_page.dart';

/// Konfigurasi rute & navigasi aplikasi HousePrice.
/// Tampilan awal aplikasi tetap mempertahankan MainNavigation dengan BottomNavigationBar.
class AppRoutes {
  AppRoutes._();

  static const String main = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String predictForm = '/predict-form';
  static const String predictResult = '/predict-result';
  static const String kprForm = '/kpr-form';
  static const String kprResult = '/kpr-result';

  /// Rute publik yang dapat dibuka langsung tanpa guard
  static Map<String, WidgetBuilder> get publicRoutes => {
    main: (_) => const MainNavigationPage(),
    splash: (_) => const SplashPage(),
    onboarding: (_) => const OnboardingPage(),
    landing: (_) => const MainNavigationPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    home: (_) => const HomePage(),
  };

  /// Seluruh builder halaman yang terdaftar di dalam aplikasi
  static Map<String, WidgetBuilder> get allRoutes => {
    ...publicRoutes,
    predictForm: (_) => const PredictFormPage(),
    predictResult: (_) => const ResultPage(),
    kprForm: (_) => const KprFormPage(),
    kprResult: (_) => const KprResultPage(),
  };

  /// Routes publik digunakan untuk navigasi langsung di MaterialApp
  static Map<String, WidgetBuilder> get routes => publicRoutes;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';

    // Navigation Guard untuk fitur privat (Prediksi & KPR) yang memerlukan login
    if (AuthSession.requiresAuth(routeName) && !AuthSession.isLoggedIn) {
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: settings,
      );
    }

    final builder = allRoutes[routeName];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
        body: Center(
          child: Text('Rute $routeName tidak terdaftar'),
        ),
      ),
    );
  }
}
