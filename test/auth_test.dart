import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houseprice_mobile_app/core/session/auth_session.dart';
import 'package:houseprice_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:houseprice_mobile_app/features/auth/presentation/pages/register_page.dart';
import 'package:houseprice_mobile_app/routes.dart';

void main() {
  group('Auth Pages UI & Validation Tests', () {
    testWidgets('LoginPage renders correctly and validates empty inputs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify header and fields exist
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Daftar Sekarang'), findsOneWidget);

      // Tap submit with empty inputs
      await tester.ensureVisible(find.text('Masuk ke Akun'));
      await tester.tap(find.text('Masuk ke Akun'));
      await tester.pump();

      // Check validation error messages
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('RegisterPage renders correctly and validates invalid inputs', (WidgetTester tester) async {
      // Set test window size to phone aspect ratio
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Verify header and fields exist
      expect(find.text('Buat Akun Baru'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Konfirmasi Kata Sandi'), findsOneWidget);
      expect(find.text('Daftar Akun Baru'), findsOneWidget);
      expect(find.text('Masuk di Sini'), findsOneWidget);

      // Tap submit with empty inputs
      await tester.ensureVisible(find.text('Daftar Akun Baru'));
      await tester.tap(find.text('Daftar Akun Baru'));
      await tester.pump();

      // Check validation error messages
      expect(find.text('Nama lengkap tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
      expect(find.text('Konfirmasi kata sandi tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('LoginPage validates unregistered email before account is created', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Clear any registered accounts
      AuthSession.registeredAccounts.clear();

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'userbaru@example.com');
      await tester.enterText(textFields.at(1), 'PasswordBaru123');
      await tester.pump();

      // Submit login
      await tester.ensureVisible(find.text('Masuk ke Akun'));
      await tester.tap(find.text('Masuk ke Akun'));
      await tester.pump();

      // Verify unregistered email warning
      expect(find.text('Email belum terdaftar. Silakan daftar akun baru terlebih dahulu.'), findsOneWidget);
    });

    testWidgets('RegisterPage registers account and allows login with newly created account', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthSession.registeredAccounts.clear();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const RegisterPage(),
            AppRoutes.login: (_) => const LoginPage(),
            AppRoutes.landing: (_) => const Scaffold(body: Text('Landing Screen')),
          },
        ),
      );

      // Enter registration details using indices of text fields
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Budi Santoso');
      await tester.enterText(textFields.at(1), 'budi@example.com');
      await tester.enterText(textFields.at(2), 'BudiPass123');
      await tester.enterText(textFields.at(3), 'BudiPass123');
      await tester.pump();

      // Tap Daftar Akun Baru
      await tester.ensureVisible(find.text('Daftar Akun Baru'));
      await tester.tap(find.text('Daftar Akun Baru'));
      await tester.pumpAndSettle();

      // Verify navigated to LoginPage and account registered
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(AuthSession.registeredAccounts.containsKey('budi@example.com'), isTrue);

      // Now enter registered credentials on LoginPage
      final loginFields = find.byType(TextField);
      await tester.enterText(loginFields.at(0), 'budi@example.com');
      await tester.enterText(loginFields.at(1), 'BudiPass123');
      await tester.pump();

      // Submit login
      await tester.ensureVisible(find.text('Masuk ke Akun'));
      await tester.tap(find.text('Masuk ke Akun'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(AuthSession.isLoggedIn, isTrue);
      expect(find.text('Landing Screen'), findsOneWidget);
    });
  });
}
