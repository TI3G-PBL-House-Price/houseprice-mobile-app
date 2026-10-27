import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../routes.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';

/// Halaman Pendaftaran Akun / Register.
/// Referensi: docs/docs/design-system.md § 3C & docs/docs/testing.md § 2A
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? nameErr;
    String? emailErr;
    String? passwordErr;
    String? confirmPasswordErr;

    // Validasi Nama Lengkap (BVA: min 3 karakter, maks 100)
    if (name.isEmpty) {
      nameErr = 'Nama lengkap tidak boleh kosong';
    } else if (name.length < 3) {
      nameErr = 'Nama lengkap minimal 3 karakter';
    }

    // Validasi Email (EP/BVA format baku)
    if (email.isEmpty) {
      emailErr = 'Email tidak boleh kosong';
    } else if (!_emailRegex.hasMatch(email)) {
      emailErr = 'Format alamat email tidak valid';
    }

    // Validasi Kata Sandi (BVA: min 8 karakter)
    if (password.isEmpty) {
      passwordErr = 'Kata sandi tidak boleh kosong';
    } else if (password.length < 8) {
      passwordErr = 'Kata sandi minimal 8 karakter';
    }

    // Validasi Konfirmasi Kata Sandi
    if (confirmPassword.isEmpty) {
      confirmPasswordErr = 'Konfirmasi kata sandi tidak boleh kosong';
    } else if (confirmPassword != password) {
      confirmPasswordErr = 'Konfirmasi kata sandi tidak cocok';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    return nameErr == null &&
        emailErr == null &&
        passwordErr == null &&
        confirmPasswordErr == null;
  }

  void _handleRegister() {
    if (_validateForm()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      AuthSession.register(name: name, email: email, password: password);

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pendaftaran berhasil! Akun $email siap digunakan untuk login.'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const AuthHeader(
                  title: 'Buat Akun Baru',
                  subtitle: 'Daftar sekarang untuk menyimpan riwayat estimasi dan simulasi KPR ke cloud',
                ),
                const SizedBox(height: AppSizes.xxl),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field Nama Lengkap
                      AuthTextField(
                        label: 'Nama Lengkap',
                        hint: 'Contoh: Budi Santoso',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.base),

                      // Field Email
                      AuthTextField(
                        label: 'Alamat Email',
                        hint: 'nama@domain.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.base),

                      // Field Kata Sandi
                      AuthTextField(
                        label: 'Kata Sandi',
                        hint: 'Minimal 8 karakter',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        errorText: _passwordError,
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.base),

                      // Field Konfirmasi Kata Sandi
                      AuthTextField(
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Ulangi kata sandi Anda',
                        prefixIcon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        errorText: _confirmPasswordError,
                        onChanged: (_) {
                          if (_confirmPasswordError != null) {
                            setState(() => _confirmPasswordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Tombol Daftar CTA
                      GradientButton(
                        text: 'Daftar Akun Baru',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Footer link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTypography.bodyRegular,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        'Masuk di Sini',
                        style: AppTypography.inputContent.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
