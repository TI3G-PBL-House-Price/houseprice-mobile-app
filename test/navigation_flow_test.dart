import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:houseprice_mobile_app/core/session/auth_session.dart';
import 'package:houseprice_mobile_app/features/history/presentation/widgets/history_bottom_sheet.dart';
import 'package:houseprice_mobile_app/features/kpr/presentation/pages/kpr_result_page.dart';
import 'package:houseprice_mobile_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:houseprice_mobile_app/features/prediction/presentation/pages/result_page.dart';
import 'package:houseprice_mobile_app/main.dart';
import 'package:houseprice_mobile_app/routes.dart';

void main() {
  group('Navigation Flow Tests (Splash -> Carousel -> Landing -> Login)', () {
    testWidgets('1. Splash Page renders logo, title, and loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.splash),
      );

      expect(find.text('HousePrice'), findsOneWidget);
      expect(find.text('Solusi Cerdas Valuasi Properti'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance timer to trigger navigation to onboarding
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Estimasi Harga Properti Akurat'), findsOneWidget);
    });

    testWidgets('2. Onboarding Carousel renders slides, Next, Skip, and Get Started buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingPage(),
        ),
      );

      // Verify first slide elements
      expect(find.text('Lewati'), findsOneWidget);
      expect(find.text('Estimasi Harga Properti Akurat'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);

      // Tap Lanjut to go to slide 2
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Simulasi KPR Transparan'), findsOneWidget);

      // Tap Lanjut to go to slide 3
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Evaluasi Kewajaran Pasar'), findsOneWidget);
      expect(find.text('Mulai Sekarang'), findsOneWidget);
    });

    testWidgets('3. Landing Page can be accessed publicly without login and shows bottom menu bar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.landing),
      );
      await tester.pumpAndSettle();

      // Verify bottom menu bar and tabs
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Estimasi'), findsOneWidget);
      expect(find.text('KPR'), findsOneWidget);

      // Verify public information accessible without login
      expect(find.text('HousePrice'), findsOneWidget);
      expect(find.text('DKI Jakarta'), findsOneWidget);
      expect(find.text('Statistik Wilayah'), findsOneWidget);
      expect(find.text('Rata-rata harga per kota administrasi'), findsOneWidget);
    });

    testWidgets('4. Tapping Prediksi (Estimasi) on Landing Page redirects unauthenticated user to Login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Ensure user is not logged in
      AuthSession.isLoggedIn = false;

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.landing),
      );
      await tester.pumpAndSettle();

      // Tap Estimasi tab on BottomNavigationBar
      await tester.tap(find.text('Estimasi'));
      await tester.pumpAndSettle();

      // Should be redirected to Login page
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });

    testWidgets('5. Tapping KPR on Landing Page redirects unauthenticated user to Login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Ensure user is not logged in
      AuthSession.isLoggedIn = false;

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.landing),
      );
      await tester.pumpAndSettle();

      // Tap KPR tab on BottomNavigationBar
      await tester.tap(find.text('KPR'));
      await tester.pumpAndSettle();

      // Should be redirected to Login page
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });

    testWidgets('6. Direct access to protected route /predict-form redirects to Login via onGenerateRoute', (WidgetTester tester) async {
      AuthSession.isLoggedIn = false;

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.predictForm),
      );
      await tester.pumpAndSettle();

      // Should show Login page because unauthenticated
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });

    testWidgets('7. Tapping Riwayat when unauthenticated redirects to Login page', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthSession.isLoggedIn = false;

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.landing),
      );
      await tester.pumpAndSettle();

      // Tap Riwayat icon button on the AppBar
      await tester.tap(find.byTooltip('Riwayat'));
      await tester.pumpAndSettle();

      // Should redirect to Login page
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });

    testWidgets('8. History bottom sheet opens safely when user is authenticated', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthSession.isLoggedIn = true;

      await tester.pumpWidget(
        const HousePriceApp(initialRoute: AppRoutes.landing),
      );
      await tester.pumpAndSettle();

      // Tap Riwayat icon button on the AppBar
      await tester.tap(find.byTooltip('Riwayat'));
      await tester.pumpAndSettle();

      // Verify HistoryBottomSheet renders properly without throwing LocaleDataException
      expect(find.text('Riwayat Kalkulasi'), findsOneWidget);
      expect(find.text('3 catatan tersimpan'), findsOneWidget);
      expect(find.text('Jakarta Selatan - Kebayoran Baru'), findsOneWidget);
      expect(find.text('Simulasi KPR - 20 Tahun'), findsOneWidget);
      expect(find.text('Jakarta Pusat - Menteng'), findsOneWidget);
    });

    testWidgets('9. ResultPage has only "Hitung Ulang" button (no "Simpan" or "Bagikan Estimasi Nilai")', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 'Hitung Ulang' exists
      expect(find.text('Hitung Ulang'), findsOneWidget);

      // Verify 'Simpan' and 'Bagikan Estimasi Nilai' are removed
      expect(find.text('Simpan'), findsNothing);
      expect(find.text('Bagikan Estimasi Nilai'), findsNothing);
    });

    testWidgets('10. KprResultPage has only "Hitung Ulang" button (no "Simpan Hasil Simulasi ke Riwayat")', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KprResultPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 'Hitung Ulang' exists
      expect(find.text('Hitung Ulang'), findsOneWidget);

      // Verify 'Simpan Hasil Simulasi ke Riwayat' is removed
      expect(find.text('Simpan Hasil Simulasi ke Riwayat'), findsNothing);
    });

    testWidgets('11. Submitting Predict and KPR calculations automatically adds records to history', (WidgetTester tester) async {
      HistoryBottomSheet.resetHistory();

      // Submit prediction
      HistoryBottomSheet.addRecord(
        type: 'prediksi',
        location: 'Jakarta Barat - Kebon Jeruk',
        result: 3200000000,
      );

      // Submit KPR
      HistoryBottomSheet.addRecord(
        type: 'kpr',
        location: 'Simulasi KPR - 15 Tahun',
        result: 9500000,
      );

      AuthSession.isLoggedIn = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryBottomSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 5 records now (3 initial + 2 new)
      expect(find.text('5 catatan tersimpan'), findsOneWidget);
      expect(find.text('Jakarta Barat - Kebon Jeruk'), findsOneWidget);
      expect(find.text('Simulasi KPR - 15 Tahun'), findsOneWidget);

      // Clean up for other tests
      HistoryBottomSheet.resetHistory();
    });
  });
}
