import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';
import '../../business_logic/kpr_calculator.dart';
import '../../utils/currency_formatter.dart';
import 'kpr_result_page.dart';

/// Layar Form Kalkulator KPR (FR-MOB-05).
/// Referensi: design-system.md § 3B – Struktur Kartu Form Kalkulator KPR
/// Logika kalkulasi ada di business_logic/kpr_calculator.dart
/// Tanggung jawab: Naufal Abid Aurizky
class KprFormPage extends StatefulWidget {
  const KprFormPage({super.key});

  @override
  State<KprFormPage> createState() => _KprFormPageState();
}

class _KprFormPageState extends State<KprFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _hargaCtrl = TextEditingController();
  final _dpCtrl = TextEditingController();
  final _bungaCtrl = TextEditingController(text: '7.5');
  final _tenorCtrl = TextEditingController(text: '20');
  final _pendapatanCtrl = TextEditingController();
  final _cicilanLainCtrl = TextEditingController(text: '0');

  int _selectedPeriodTab = 0; // 0 = Bulanan, 1 = Tahunan

  @override
  void dispose() {
    _hargaCtrl.dispose();
    _dpCtrl.dispose();
    _bungaCtrl.dispose();
    _tenorCtrl.dispose();
    _pendapatanCtrl.dispose();
    _cicilanLainCtrl.dispose();
    super.dispose();
  }

  /// Proses kalkulasi — logika ada di business_logic/kpr_calculator.dart
  void _hitung() {
    if (!_formKey.currentState!.validate()) return;

    final harga = double.tryParse(_hargaCtrl.text.replaceAll('.', '')) ?? 0;
    final dp = double.tryParse(_dpCtrl.text.replaceAll('.', '')) ?? 0;
    final bunga = double.tryParse(_bungaCtrl.text) ?? 0;
    final tenor = int.tryParse(_tenorCtrl.text) ?? 0;
    final pendapatan =
        double.tryParse(_pendapatanCtrl.text.replaceAll('.', '')) ?? 0;
    final cicilanLain =
        double.tryParse(_cicilanLainCtrl.text.replaceAll('.', '')) ?? 0;

    final result = KprCalculator.hitung(
      hargaProperti: harga,
      uangMukaRupiah: dp,
      sukuBungaTahunan: bunga,
      tenorTahun: tenor,
      pendapatanBersih: pendapatan,
      cicilanLainBulanan: cicilanLain,
    );

    HistoryBottomSheet.addRecord(
      type: 'kpr',
      location: 'Simulasi KPR - $tenor Tahun',
      result: result.angsuranBulanan.round(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KprResultPage(
          result: result,
          hargaProperti: harga,
          sukuBunga: bunga,
          tenor: tenor,
          pendapatanBersih: pendapatan,
          showTahunan: _selectedPeriodTab == 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Simulasi KPR', style: AppTypography.sectionHeader),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Kalkulator KPR',
                style: AppTypography.headlineBold,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Simulasikan cicilan kredit pemilikan rumah dengan metode bunga anuitas',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Pemilih Periode (Bulanan / Tahunan) ───────────────────────
              _buildPeriodSelector(),
              const SizedBox(height: AppSizes.lg),

              // ── Input Finansial ───────────────────────────────────────────
              SectionCard(
                icon: Icons.account_balance_rounded,
                title: 'Data Finansial',
                badge: 'Rupiah',
                children: [
                  // Harga properti
                  _buildField(
                    controller: _hargaCtrl,
                    label: 'Nilai Properti / Harga Rumah',
                    hint: 'Contoh: 2.500.000.000',
                    prefixIcon: Icons.home_rounded,
                    useThousandFormatter: true,
                    validator: KprInputValidator.hargaProperti,
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Uang muka
                  _buildField(
                    controller: _dpCtrl,
                    label: 'Uang Muka / DP (Rupiah)',
                    hint: 'Contoh: 500.000.000 (20%)',
                    prefixIcon: Icons.payments_rounded,
                    helperText: 'Standar minimum DP perbankan 10% – 20%',
                    useThousandFormatter: true,
                    validator: (v) {
                      final harga = double.tryParse(
                              _hargaCtrl.text.replaceAll('.', '')) ??
                          0;
                      return KprInputValidator.uangMuka(v, harga);
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Suku bunga
                  _buildField(
                    controller: _bungaCtrl,
                    label: 'Suku Bunga Tetap per Tahun (%)',
                    hint: 'Contoh: 6.5',
                    prefixIcon: Icons.percent_rounded,
                    suffixText: '% p.a.',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: KprInputValidator.sukuBunga,
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Tenor
                  _buildField(
                    controller: _tenorCtrl,
                    label: 'Tenor Pinjaman (Tahun)',
                    hint: 'Contoh: 20',
                    prefixIcon: Icons.calendar_today_rounded,
                    suffixText: 'Tahun',
                    helperText: 'Pilihan tenor umum: 10, 15, 20, 25 tahun',
                    validator: KprInputValidator.tenor,
                  ),
                ],
              ),

              // ── Seksi 2: Profil Pendapatan ────────────────────────────────
              SectionCard(
                icon: Icons.wallet_rounded,
                title: 'Profil Pendapatan & Beban',
                badge: 'Evaluasi DSR',
                children: [
                  _buildField(
                    controller: _pendapatanCtrl,
                    label: 'Total Pendapatan Bersih Bulanan',
                    hint: 'Contoh: 25.000.000',
                    prefixIcon: Icons.attach_money_rounded,
                    helperText:
                        'Akumulasi gaji pemohon + pasangan jika joint income',
                    useThousandFormatter: true,
                    validator: KprInputValidator.pendapatanBersih,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildField(
                    controller: _cicilanLainCtrl,
                    label: 'Total Cicilan Lain yang Sedang Berjalan',
                    hint: 'Contoh: 0',
                    prefixIcon: Icons.credit_card_rounded,
                    helperText:
                        'Cicilan kendaraan, kartu kredit, pinjaman lain',
                    useThousandFormatter: true,
                    validator: KprInputValidator.cicilanLain,
                  ),
                ],
              ),

              // ── Kotak Informasi DSR ───────────────────────────────────────
              _buildDsrInfoBox(),
              const SizedBox(height: AppSizes.lg),

              // ── Tombol CTA ────────────────────────────────────────────────
              GradientButton(
                text: 'Hitung Simulasi KPR',
                icon: Icons.calculate_rounded,
                onPressed: _hitung,
              ),
              const SizedBox(height: AppSizes.sm),
              Center(
                child: TextButton(
                  onPressed: () {
                    _hargaCtrl.clear();
                    _dpCtrl.clear();
                    _bungaCtrl.text = '7.5';
                    _tenorCtrl.text = '20';
                    _pendapatanCtrl.clear();
                    _cicilanLainCtrl.text = '0';
                    _formKey.currentState?.reset();
                  },
                  child: Text(
                    'Atur Ulang Form',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget input field yang dapat dikonfigurasi
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? suffixText,
    String? helperText,
    TextInputType? keyboardType,
    bool useThousandFormatter = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: useThousandFormatter
          ? [ThousandsSeparatorInputFormatter()]
          : null,
      style: AppTypography.inputContent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppColors.textHint, size: AppSizes.iconSm),
        suffixText: suffixText,
        helperText: helperText,
        helperMaxLines: 2,
      ),
      validator: validator,
    );
  }

  /// Tab segmen atas: Bulanan vs Tahunan
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _buildPeriodTab('Bulanan', 0),
          _buildPeriodTab('Tahunan', 1),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isActive = _selectedPeriodTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriodTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.inputContent.copyWith(
                color: isActive ? AppColors.primaryBlue : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Info box rekomendasi DSR
  Widget _buildDsrInfoBox() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.infoBlueBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppSizes.iconMd,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Rasio Cicilan (DSR)',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Rekomendasi cicilan maksimal 30% – 40% dari total pendapatan bersih bulanan Anda sesuai standar OJK.',
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.primaryBlue.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias KprFormScreen agar kompatibel dengan penamaan lama.
typedef KprFormScreen = KprFormPage;
