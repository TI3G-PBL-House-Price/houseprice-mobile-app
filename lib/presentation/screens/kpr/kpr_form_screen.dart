import 'package:flutter/material.dart';

import '../../../business_logic/business_logic.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_card.dart';
import 'kpr_result_screen.dart';

class KprFormScreen extends StatefulWidget {
  const KprFormScreen({
    super.key,
    this.initialHargaProperti,
  });

  final double? initialHargaProperti;

  @override
  State<KprFormScreen> createState() => _KprFormScreenState();
}

class _KprFormScreenState extends State<KprFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hargaController;
  late final TextEditingController _dpController;
  late final TextEditingController _bungaController;
  late final TextEditingController _tenorController;
  late final TextEditingController _incomeController;

  int _selectedPeriodTab = 0;
  double _dpPersen = 20.0;

  @override
  void initState() {
    super.initState();

    final hargaAwal = widget.initialHargaProperti ?? 2500000000;
    final dpAwal = hargaAwal * 0.20;

    _hargaController = TextEditingController(
      text: CurrencyFormatter.format(hargaAwal),
    );
    _dpController = TextEditingController(
      text: CurrencyFormatter.format(dpAwal),
    );
    _bungaController = TextEditingController(text: '7.5');
    _tenorController = TextEditingController(text: '20');
    _incomeController = TextEditingController(
      text: CurrencyFormatter.format(25000000),
    );
  }

  @override
  void dispose() {
    _hargaController.dispose();
    _dpController.dispose();
    _bungaController.dispose();
    _tenorController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _setDpPreset(double persen) {
    setState(() {
      _dpPersen = persen;
      final harga = CurrencyFormatter.parse(_hargaController.text);
      if (harga > 0) {
        final dp = harga * (persen / 100.0);
        _dpController.text = CurrencyFormatter.format(dp);
      }
    });
  }

  void _hitungSimulasi() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon periksa kembali form input Anda'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    final harga = CurrencyFormatter.parse(_hargaController.text);
    final dp = CurrencyFormatter.parse(_dpController.text);
    final bunga = double.tryParse(_bungaController.text.replaceAll(',', '.')) ?? 7.5;
    final tenor = int.tryParse(_tenorController.text) ?? 20;
    final income = CurrencyFormatter.parse(_incomeController.text);

    final result = KprCalculator.hitung(
      hargaProperti: harga,
      uangMuka: dp,
      bungaTahunan: bunga,
      tenorTahun: tenor,
      pendapatanBulanan: income,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KprResultScreen(
          result: result,
          isTahunan: _selectedPeriodTab == 1,
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

              _buildPeriodSelector(),
              const SizedBox(height: AppSizes.lg),

              // Form Input
              SectionCard(
                icon: Icons.account_balance_rounded,
                title: 'Data Finansial',
                badge: 'Rupiah',
                children: [
                  CustomTextField(
                    label: 'Nilai Properti / Harga Rumah',
                    hint: 'Contoh: 2.500.000.000',
                    prefixIcon: Icons.home_rounded,
                    suffixText: 'Rp',
                    keyboardType: TextInputType.number,
                    controller: _hargaController,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    validator: InputValidator.validateHarga,
                    onChanged: (_) => _setDpPreset(_dpPersen),
                  ),
                  const SizedBox(height: AppSizes.md),

                  CustomTextField(
                    label: 'Uang Muka (DP)',
                    hint: 'Contoh: 500.000.000',
                    prefixIcon: Icons.savings_rounded,
                    suffixText: 'Rp',
                    keyboardType: TextInputType.number,
                    controller: _dpController,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    validator: (val) {
                      final harga = CurrencyFormatter.parse(_hargaController.text);
                      return InputValidator.validateUangMuka(val, harga);
                    },
                  ),
                  const SizedBox(height: AppSizes.xs),
                  _buildDpPresetButtons(),
                  const SizedBox(height: AppSizes.md),

                  CustomTextField(
                    label: 'Suku Bunga KPR per Tahun',
                    hint: 'Contoh: 7.5',
                    prefixIcon: Icons.percent_rounded,
                    suffixText: '% / thn',
                    helperText: 'Rata-rata suku bunga KPR bank: 7% – 12%',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _bungaController,
                    validator: InputValidator.validateBunga,
                  ),
                  const SizedBox(height: AppSizes.md),

                  CustomTextField(
                    label: 'Jangka Waktu Kredit (Tenor)',
                    hint: 'Contoh: 20',
                    prefixIcon: Icons.calendar_month_rounded,
                    suffixText: 'Tahun',
                    helperText: 'Rentang tenor: 1 s/d 35 tahun',
                    keyboardType: TextInputType.number,
                    controller: _tenorController,
                    validator: InputValidator.validateTenor,
                  ),
                  const SizedBox(height: AppSizes.md),

                  CustomTextField(
                    label: 'Pendapatan Bersih Bulanan',
                    hint: 'Contoh: 25.000.000',
                    prefixIcon: Icons.wallet_rounded,
                    suffixText: 'Rp',
                    helperText: 'Digunakan untuk evaluasi batas kemampuan bayar (DSR)',
                    keyboardType: TextInputType.number,
                    controller: _incomeController,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    validator: InputValidator.validatePendapatan,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.base),

              _buildDsrInfoBox(),
              const SizedBox(height: AppSizes.lg),

              GradientButton(
                text: 'Hitung Simulasi KPR',
                icon: Icons.calculate_rounded,
                onPressed: _hitungSimulasi,
              ),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // Preset DP Cepat
  Widget _buildDpPresetButtons() {
    return Row(
      children: [
        Text(
          'Preset DP: ',
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSizes.xs),
        for (final p in [10.0, 20.0, 30.0]) ...[
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.xs),
            child: ChoiceChip(
              label: Text('${p.toInt()}%'),
              selected: _dpPersen == p,
              onSelected: (_) => _setDpPreset(p),
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
              labelStyle: AppTypography.captionSmall.copyWith(
                color: _dpPersen == p
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                fontWeight: _dpPersen == p ? FontWeight.w700 : FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }

  // Pemilih Periode Bulanan / Tahunan
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

  // Info Panduan DSR OJK
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
          const Icon(
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
                  'Berdasarkan ketentuan Bank Indonesia & OJK, rasio angsuran maksimal yang disarankan adalah 30% – 40% dari pendapatan bersih bulanan.',
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.primaryBlue.withValues(alpha: 0.85),
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
