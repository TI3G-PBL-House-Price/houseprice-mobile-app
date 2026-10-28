import 'package:flutter/material.dart';

import '../../../business_logic/business_logic.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../history/history_bottom_sheet.dart';
import '../kpr/kpr_form_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.estimasiTengah = 2625000000,
    this.spesifikasi,
  });

  final double estimasiTengah;
  final Map<String, String>? spesifikasi;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _penawaranController;
  KewajaranResult? _kewajaranResult;

  late double _lowerBound;
  late double _upperBound;
  late double _avgPerM2;
  late final Map<String, String> _spec;

  @override
  void initState() {
    super.initState();

    _lowerBound = widget.estimasiTengah * 0.90;
    _upperBound = widget.estimasiTengah * 1.10;

    const luasBangunan = 120.0;
    _avgPerM2 = widget.estimasiTengah / luasBangunan;

    _spec = widget.spesifikasi ??
        {
          'Kota': 'Jakarta Selatan',
          'Kecamatan': 'Kebayoran Baru',
          'Luas Tanah': '140 m²',
          'Luas Bangunan': '120 m²',
          'Kamar Tidur': '3',
          'Kamar Mandi': '2',
        };

    _penawaranController = TextEditingController(
      text: CurrencyFormatter.format(2500000000),
    );

    _evaluasiKewajaran();
  }

  @override
  void dispose() {
    _penawaranController.dispose();
    super.dispose();
  }

  void _evaluasiKewajaran() {
    final penawaran = CurrencyFormatter.parse(_penawaranController.text);
    if (penawaran <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal harga penawaran yang valid'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    setState(() {
      _kewajaranResult = KewajaranCalculator.evaluasi(
        hargaPenawaran: penawaran,
        estimasiTengah: widget.estimasiTengah,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Valuasi Properti', style: AppTypography.sectionHeader),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Riwayat',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const HistoryBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          children: [
            _buildEstimationCard(),
            const SizedBox(height: AppSizes.base),

            _buildFairnessCard(),
            const SizedBox(height: AppSizes.base),

            _buildSpecCard(),
            const SizedBox(height: AppSizes.lg),

            _buildKprShortcutBanner(),
            const SizedBox(height: AppSizes.lg),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Hitung Ulang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                    label: const Text('Simpan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Valuasi tersimpan ke riwayat offline'),
                          backgroundColor: AppColors.primaryNavy,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            GradientButton(
              text: 'Bagikan Estimasi Nilai',
              icon: Icons.share_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tautan estimasi berhasil disalin'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  // Kartu Estimasi Nilai Pasar
  Widget _buildEstimationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rentang Harga Pasar Wajar (±10%)',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${CurrencyFormatter.format(_lowerBound ~/ 1000000)} Jt',
                style: AppTypography.headlineBold.copyWith(color: AppColors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Text(
                  'sampai',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Text(
                'Rp ${CurrencyFormatter.format(_upperBound ~/ 1000000)} Jt',
                style: AppTypography.headlineBold.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Estimasi Titik Tengah: ${CurrencyFormatter.formatRupiah(widget.estimasiTengah)}',
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSizes.base),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.straighten_rounded,
                  size: 16,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Rata-rata: Rp ${CurrencyFormatter.format(_avgPerM2 ~/ 1000000)} Jt / m²',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cek Kewajaran Harga Penawaran
  Widget _buildFairnessCard() {
    final res = _kewajaranResult;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.price_check_rounded,
                  size: 22,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text('Cek Kewajaran Harga', style: AppTypography.sectionHeader),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Masukkan harga penawaran penjual untuk evaluasi deviasi pasar (±10%)',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSizes.md),

          TextField(
            controller: _penawaranController,
            style: AppTypography.inputContent,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            decoration: InputDecoration(
              hintText: 'Contoh: 2.500.000.000',
              prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.textHint),
              prefixText: 'Rp  ',
              prefixStyle: AppTypography.inputContent.copyWith(color: AppColors.primaryBlue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue),
                tooltip: 'Evaluasi Sekarang',
                onPressed: _evaluasiKewajaran,
              ),
            ),
            onSubmitted: (_) => _evaluasiKewajaran(),
          ),
          const SizedBox(height: AppSizes.md),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.assessment_rounded, size: 18),
              label: const Text('Evaluasi Kewajaran'),
              onPressed: _evaluasiKewajaran,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          if (res != null) ...[
            Center(
              child: StatusBadge(
                type: res.status,
                label: res.badgeLabel,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: _getBgForStatus(res.status),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: _getColorForStatus(res.status).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: _getColorForStatus(res.status),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        res.statusJudul,
                        style: AppTypography.caption.copyWith(
                          color: _getColorForStatus(res.status),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    res.rekomendasi,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Selisih: ${res.selisihNominal >= 0 ? '+' : ''}${CurrencyFormatter.formatRupiah(res.selisihNominal)} (${res.deviasiPersen.toStringAsFixed(1)}%)',
                    style: AppTypography.captionSmall.copyWith(
                      color: _getColorForStatus(res.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Pintasan ke Simulasi KPR
  Widget _buildKprShortcutBanner() {
    final penawaran = CurrencyFormatter.parse(_penawaranController.text);
    final targetHarga = penawaran > 0 ? penawaran : widget.estimasiTengah;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 24,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingin Mengajukan KPR?',
                  style: AppTypography.inputContent.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Simulasikan cicilan per bulan dengan harga ini',
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KprFormScreen(),
                ),
              );
            },

            child: const Text('Simulasi'),
          ),
        ],
      ),
    );
  }

  // Ringkasan Spesifikasi Properti
  Widget _buildSpecCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 22,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Text('Ringkasan Spesifikasi', style: AppTypography.sectionHeader),
            ],
          ),
          const SizedBox(height: AppSizes.base),
          ..._buildSpecRows(),
        ],
      ),
    );
  }

  List<Widget> _buildSpecRows() {
    final entries = _spec.entries.toList();
    final List<Widget> rows = [];

    for (var i = 0; i < entries.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: Row(
          children: [
            Expanded(child: _buildSpecItem(entries[i].key, entries[i].value)),
            if (i + 1 < entries.length)
              Expanded(child: _buildSpecItem(entries[i + 1].key, entries[i + 1].value)),
          ],
        ),
      ));
    }
    return rows;
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.inputContent),
      ],
    );
  }

  Color _getColorForStatus(StatusType status) {
    switch (status) {
      case StatusType.murah:
        return AppColors.successGreen;
      case StatusType.wajar:
        return AppColors.infoBlue;
      case StatusType.mahal:
        return AppColors.alertRed;
    }
  }

  Color _getBgForStatus(StatusType status) {
    switch (status) {
      case StatusType.murah:
        return AppColors.successGreenBg;
      case StatusType.wajar:
        return AppColors.infoBlueBg;
      case StatusType.mahal:
        return AppColors.alertRedBg;
    }
  }
}
