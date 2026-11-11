import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../routes.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';
import '../../../kpr/business_logic/kpr_calculator.dart';
import '../../../kpr/utils/currency_formatter.dart';
import '../../data/prediction_result_data.dart';

/// Layar Hasil Estimasi & Cek Kewajaran (FR-MOB-03 & FR-MOB-04).
class ResultPage extends StatefulWidget {
  const ResultPage({super.key, this.data = PredictionResultData.sample});

  final PredictionResultData data;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  bool _saved = false;

  // ── State Cek Kewajaran ───────────────────────────────────────────────────
  final _penawaranCtrl = TextEditingController();
  KewajaranResult? _kewajaranResult;
  bool _isEvaluating = false;

  String _short(int v) =>
      'Rp ${(v / 1000000000).toStringAsFixed(2).replaceAll('.', ',')} M';

  String _full(int v) => 'Rp ${_currencyFormat.format(v)}';

  String _perM2(int v) =>
      'Rp ${(v / 1000000).toStringAsFixed(1).replaceAll('.', ',')} Jt / m\u00B2';

  @override
  void dispose() {
    _penawaranCtrl.dispose();
    super.dispose();
  }

  void _evaluasiKewajaran() {
    final rawText = _penawaranCtrl.text.replaceAll('.', '');
    final penawaran = double.tryParse(rawText) ?? 0;
    if (penawaran <= 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Masukkan harga penawaran yang valid'),
          backgroundColor: AppColors.primaryNavy,
          duration: Duration(seconds: 2),
        ));
      return;
    }

    setState(() => _isEvaluating = true);

    final d = widget.data;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final result = KewajaranCalculator.evaluasi(
        hargaPenawaran: penawaran,
        estimasiMin: d.lowerBound.toDouble(),
        estimasiMax: d.upperBound.toDouble(),
      );
      setState(() {
        _kewajaranResult = result;
        _isEvaluating = false;
      });
    });
  }

  void _save() {
    if (_saved) return;

    if (!AuthSession.isLoggedIn) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Silakan masuk terlebih dahulu untuk menyimpan estimasi.'),
            backgroundColor: AppColors.primaryNavy,
            duration: Duration(seconds: 2),
          ),
        );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final d = widget.data;
    HistoryBottomSheet.addRecord(
      type: 'prediksi',
      location: '${d.city} - ${d.district}',
      result: d.midPrice,
    );
    setState(() => _saved = true);

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Estimasi tersimpan ke Riwayat'),
          backgroundColor: AppColors.primaryNavy,
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _share() async {
    final d = widget.data;
    final text = 'Estimasi Nilai Pasar Properti\n'
        '${d.district}, ${d.city}\n'
        'Luas tanah ${d.landArea} m\u00B2, luas bangunan ${d.buildingArea} m\u00B2\n'
        '${_short(d.lowerBound)} sampai ${_short(d.upperBound)}\n'
        '(${_full(d.lowerBound)} - ${_full(d.upperBound)})';

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Estimasi disalin ke clipboard'),
          backgroundColor: AppColors.primaryNavy,
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hasil Valuasi Properti',
          style: AppTypography.sectionHeader,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Riwayat',
            onPressed: () {
              HistoryBottomSheet.show(context);
            },
          ),
          if (!AuthSession.isLoggedIn)
            TextButton.icon(
              icon: const Icon(Icons.login_rounded, size: 18, color: AppColors.primaryBlue),
              label: Text(
                'Masuk',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
          const SizedBox(width: AppSizes.xs),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.base),
              child: Column(
                children: [
                  _buildEstimationCard(d),
                  const SizedBox(height: AppSizes.base),
                  _buildDataCard(d),
                  const SizedBox(height: AppSizes.base),
                  _buildFairnessCard(),
                  const SizedBox(height: AppSizes.base),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryNavy.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// CARD 1: Estimasi Nilai Pasar
  Widget _buildEstimationCard(PredictionResultData d) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'ESTIMASI NILAI PASAR',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSizes.lg),
                Text('Rentang Harga Pasar Wajar', style: AppTypography.bodySmall),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: AppSizes.sm,
                  children: [
                    Text(_short(d.lowerBound), style: AppTypography.headlineBold),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('sampai', style: AppTypography.bodySmall),
                    ),
                    Text(
                      _short(d.upperBound),
                      style: AppTypography.headlineBold.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  '(${_full(d.lowerBound)} - ${_full(d.upperBound)})',
                  style: AppTypography.captionSmall,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.base,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Harga Rata-Rata Bangunan', style: AppTypography.bodySmall),
                Text(
                  _perM2(d.avgPerM2),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CARD 2: Berdasarkan Data Properti
  Widget _buildDataCard(PredictionResultData d) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded, size: 22, color: AppColors.primaryBlue),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text('Berdasarkan Data Properti', style: AppTypography.sectionHeader),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Ubah',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _InfoTile(icon: Icons.location_city_rounded, label: 'Kota', value: d.city),
          const SizedBox(height: AppSizes.sm),
          _InfoTile(icon: Icons.location_on_rounded, label: 'Kecamatan', value: d.district),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.crop_landscape_rounded,
                  label: 'Luas Tanah',
                  value: '${d.landArea} m\u00B2',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.home_rounded,
                  label: 'Luas Bangunan',
                  value: '${d.buildingArea} m\u00B2',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.bed_rounded,
                  label: 'Kamar Tidur',
                  value: '${d.bedrooms} Kamar',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.shower_rounded,
                  label: 'Kamar Mandi',
                  value: '${d.bathrooms} Kamar',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _InfoTile(
            icon: Icons.directions_car_rounded,
            label: 'Kapasitas Garasi',
            value: '${d.garage} Mobil / Carport',
          ),
        ],
      ),
    );
  }

  /// CARD 3: Cek Kewajaran Harga Penawaran (dari fitur price-fairness-check)
  Widget _buildFairnessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.base),
      decoration: _cardDecoration(),
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
                child: const Icon(Icons.price_check_rounded, size: 22, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text('Cek Kewajaran Harga', style: AppTypography.sectionHeader),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Masukkan harga penawaran penjual untuk evaluasi kewajaran terhadap estimasi pasar ML.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: _penawaranCtrl,
            style: AppTypography.inputContent,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            decoration: InputDecoration(
              hintText: 'Contoh: 2.500.000.000',
              prefixIcon: const Icon(Icons.payments_rounded, color: AppColors.textHint),
              prefixText: 'Rp  ',
              prefixStyle: AppTypography.inputContent.copyWith(color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isEvaluating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.assessment_rounded, size: 18),
              label: Text(_isEvaluating ? 'Mengevaluasi...' : 'Evaluasi Kewajaran'),
              onPressed: _isEvaluating ? null : _evaluasiKewajaran,
            ),
          ),

          // ── Hasil Evaluasi (muncul setelah tombol ditekan) ───────────────
          if (_kewajaranResult != null) ...[
            const SizedBox(height: AppSizes.base),
            const Divider(),
            const SizedBox(height: AppSizes.sm),
            _buildKewajaranResult(_kewajaranResult!),
          ],
        ],
      ),
    );
  }

  /// Widget hasil evaluasi kewajaran harga
  Widget _buildKewajaranResult(KewajaranResult kr) {
    final StatusType badgeType;
    final Color statusColor;
    final IconData statusIcon;

    switch (kr.status) {
      case StatusKewajaran.murah:
        badgeType = StatusType.murah;
        statusColor = AppColors.successGreen;
        statusIcon = Icons.trending_down_rounded;
      case StatusKewajaran.wajar:
        badgeType = StatusType.wajar;
        statusColor = AppColors.infoBlue;
        statusIcon = Icons.check_circle_outline_rounded;
      case StatusKewajaran.mahal:
        badgeType = StatusType.mahal;
        statusColor = AppColors.alertRed;
        statusIcon = Icons.trending_up_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge besar
        Center(
          child: Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 40),
              const SizedBox(height: AppSizes.sm),
              StatusBadge(type: badgeType, label: kr.labelStatus),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.base),

        // Perbandingan harga
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _nilaiBox('Harga Penawaran',
                CurrencyFormatter.formatCompact(kr.hargaPenawaran), statusColor),
            Container(width: 1, height: 50, color: AppColors.inputSurface),
            _nilaiBox('Estimasi Pasar',
                CurrencyFormatter.formatCompact(kr.hargaEstimasi), AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        // Deviasi
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(Icons.percent, color: statusColor, size: 20),
            const SizedBox(width: AppSizes.sm),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deviasi Harga',
                  style: AppTypography.captionSmall
                      .copyWith(color: AppColors.textSecondary)),
              Text(
                '${kr.deviasi >= 0 ? '+' : ''}${kr.deviasi.toStringAsFixed(1)}% dari estimasi pasar',
                style: AppTypography.caption
                    .copyWith(fontWeight: FontWeight.bold, color: statusColor),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: AppSizes.sm),

        // Saran
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.inputSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(kr.saran,
                  style: AppTypography.captionSmall
                      .copyWith(color: AppColors.textSecondary, height: 1.5)),
            ),
          ]),
        ),
        const SizedBox(height: AppSizes.sm),

        // Rentang kewajaran
        _batasRow('Batas Bawah (Murah)',
            CurrencyFormatter.formatRupiah(kr.batasWajarBawah), AppColors.successGreen),
        const SizedBox(height: 4),
        _batasRow('Estimasi Nilai Tengah',
            CurrencyFormatter.formatRupiah(kr.hargaEstimasi), AppColors.primaryBlue),
        const SizedBox(height: 4),
        _batasRow('Batas Atas (Mahal)',
            CurrencyFormatter.formatRupiah(kr.batasWajarAtas), AppColors.alertRed),
      ],
    );
  }

  Widget _nilaiBox(String label, String value, Color color) {
    return Column(children: [
      Text(label,
          style: AppTypography.captionSmall
              .copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(value,
          style: AppTypography.caption
              .copyWith(fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _batasRow(String label, String value, Color color) {
    return Row(children: [
      Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: AppSizes.sm),
      Expanded(
          child: Text(label,
              style: AppTypography.captionSmall
                  .copyWith(color: AppColors.textSecondary))),
      Text(value,
          style: AppTypography.caption
              .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]);
  }

  /// Tombol aksi bawah: Hitung Ulang, Simpan, Bagikan
  Widget _buildActions() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.base,
        AppSizes.md,
        AppSizes.base,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _secondaryButton(
                    icon: Icons.refresh_rounded,
                    label: 'Hitung Ulang',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _secondaryButton(
                    icon: _saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: _saved ? 'Tersimpan' : 'Simpan',
                    onPressed: _save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Bagikan Estimasi Nilai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.inputSurface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.captionSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias ResultScreen agar kompatibel dengan penamaan lama.
typedef ResultScreen = ResultPage;