import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../history/presentation/widgets/history_bottom_sheet.dart';
import '../../../home/data/market_service.dart';
import '../../data/prediction_result_data.dart';
import '../../data/prediction_service.dart';
import 'result_page.dart';

/// Layar Form Prediksi ML (FR-MOB-02).
/// Form input parameter properti yang terhubung langsung ke inferensi Flask API ML v2.
class PredictFormPage extends StatefulWidget {
  const PredictFormPage({super.key});

  @override
  State<PredictFormPage> createState() => _PredictFormPageState();
}

class _PredictFormPageState extends State<PredictFormPage> {
  // Opsi wilayah (default fallback, diperbarui secara dinamis via MarketService)
  List<String> _kotaOptions = MarketService.defaultCities;
  Map<String, List<String>> _kecamatanMap = MarketService.defaultDistrictMap;

  String? _selectedKota;
  String? _selectedKecamatan;

  // Controllers untuk parameter properti input model
  late final TextEditingController _bedController;
  late final TextEditingController _bathController;
  late final TextEditingController _carportController;
  late final TextEditingController _landAreaController;
  late final TextEditingController _buildingAreaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bedController = TextEditingController(text: '3');
    _bathController = TextEditingController(text: '2');
    _carportController = TextEditingController(text: '1');
    _landAreaController = TextEditingController(text: '140');
    _buildingAreaController = TextEditingController(text: '120');

    _loadMasterLocations();
  }

  @override
  void dispose() {
    _bedController.dispose();
    _bathController.dispose();
    _carportController.dispose();
    _landAreaController.dispose();
    _buildingAreaController.dispose();
    super.dispose();
  }

  /// Memuat referensi master lokasi aktif dari Flask Backend (GET /api/v1/locations).
  Future<void> _loadMasterLocations() async {
    try {
      final res = await MarketService.fetchLocations();
      if (!mounted) return;
      final cities = res['cities'] as List<String>?;
      final districtMap = res['districtMap'] as Map<String, List<String>>?;
      if (cities != null && cities.isNotEmpty && districtMap != null) {
        setState(() {
          _kotaOptions = cities;
          _kecamatanMap = districtMap;
        });
      }
    } catch (_) {}
  }

  /// Eksekusi estimasi harga properti melalui backend ML atau fallback offline.
  Future<void> _handlePredict() async {
    if (_selectedKota == null || _selectedKecamatan == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Kota Administrasi dan Kecamatan terlebih dahulu'),
          backgroundColor: AppColors.alertRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final landArea = double.tryParse(_landAreaController.text.trim()) ?? 0;
    final buildingArea = double.tryParse(_buildingAreaController.text.trim()) ?? 0;
    final bed = int.tryParse(_bedController.text.trim()) ?? 0;
    final bath = int.tryParse(_bathController.text.trim()) ?? 0;
    final carport = int.tryParse(_carportController.text.trim()) ?? 0;

    if (landArea < 1 || buildingArea < 1) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Luas tanah dan luas bangunan minimal 1 m²'),
          backgroundColor: AppColors.alertRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Di lingkungan unit/widget test, gunakan jalur mock instan
    if (AuthSession.isTestMode) {
      final sample = PredictionResultData.sample;
      final data = sample.copyWith(
        city: _selectedKota,
        district: _selectedKecamatan ?? '-',
        landArea: landArea.round(),
        buildingArea: buildingArea.round(),
        bedrooms: bed,
        bathrooms: bath,
        garage: carport,
      );
      HistoryBottomSheet.addRecord(
        type: 'prediksi',
        location: '${data.city} - ${data.district}',
        result: data.midPrice,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultPage(data: data)),
        );
      }
      return;
    }

    // Jalur produksi: Panggil REST API Flask POST /api/v1/predict
    try {
      final resultData = await PredictionService.predictPrice(
        city: _selectedKota!,
        district: _selectedKecamatan!,
        surfaceArea: landArea,
        buildingArea: buildingArea,
        bed: bed,
        bath: bath,
        carport: carport,
      );

      // Simpan ke riwayat kalkulasi lokal & server
      HistoryBottomSheet.addRecord(
        type: 'prediksi',
        location: '${resultData.city} - ${resultData.district}',
        result: resultData.midPrice,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(data: resultData)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showConnectionErrorDialog(
        errorMessage: e.toString(),
        onUseOffline: () {
          final fallbackData = PredictionService.offlineFallback(
            city: _selectedKota!,
            district: _selectedKecamatan!,
            surfaceArea: landArea,
            buildingArea: buildingArea,
            bed: bed,
            bath: bath,
            carport: carport,
          );
          HistoryBottomSheet.addRecord(
            type: 'prediksi',
            location: '${fallbackData.city} - ${fallbackData.district}',
            result: fallbackData.midPrice,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResultPage(data: fallbackData)),
          );
        },
      );
    }
  }

  void _showConnectionErrorDialog({
    required String errorMessage,
    required VoidCallback onUseOffline,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.wifi_off_rounded, color: AppColors.alertRed),
            SizedBox(width: AppSizes.sm),
            Text('Koneksi Backend Flask'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gagal terhubung ke model Machine Learning Flask backend. Pastikan server Flask sudah berjalan di komputer:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.inputSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: SelectableText(
                'python run.py\n(Host: 127.0.0.1:5000 / 10.0.2.2:5000)',
                style: AppTypography.captionSmall.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Detail: $errorMessage',
              style: AppTypography.captionSmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onUseOffline();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Gunakan Estimasi Offline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estimasi Harga', style: AppTypography.sectionHeader),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Estimasi Biaya Properti',
              style: AppTypography.headlineBold,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Masukkan spesifikasi properti untuk mendapatkan estimasi harga pasar dari model Machine Learning',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.lg),

            // Seksi 1: Wilayah & Lokasi
            SectionCard(
              icon: Icons.location_on_rounded,
              title: 'Wilayah & Lokasi',
              badge: 'DKI Jakarta',
              children: [
                _buildDropdown(
                  label: 'Kota Administrasi',
                  hint: 'Pilih kota',
                  value: _selectedKota,
                  items: _kotaOptions,
                  icon: Icons.location_city_rounded,
                  onChanged: (val) {
                    setState(() {
                      _selectedKota = val;
                      _selectedKecamatan = null;
                    });
                  },
                ),
                const SizedBox(height: AppSizes.md),
                _buildDropdown(
                  label: 'Kecamatan',
                  hint: _selectedKota == null
                      ? 'Pilih kota terlebih dahulu'
                      : 'Pilih kecamatan',
                  value: _selectedKecamatan,
                  items: (_selectedKota != null && _kecamatanMap.containsKey(_selectedKota))
                      ? _kecamatanMap[_selectedKota]!
                      : [],
                  icon: Icons.map_rounded,
                  onChanged: _selectedKota != null
                      ? (val) => setState(() => _selectedKecamatan = val)
                      : null,
                ),
              ],
            ),

            // Seksi 2: Tata Ruang, Kamar & Garasi
            SectionCard(
              icon: Icons.grid_view_rounded,
              title: 'Tata Ruang & Fasilitas',
              badge: 'Spesifikasi',
              children: [
                CustomTextField(
                  label: 'Jumlah Kamar Tidur',
                  hint: 'Contoh: 3',
                  prefixIcon: Icons.bed_rounded,
                  controller: _bedController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Jumlah Kamar Mandi',
                  hint: 'Contoh: 2',
                  prefixIcon: Icons.shower_rounded,
                  controller: _bathController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Kapasitas Garasi / Carport',
                  hint: 'Contoh: 1',
                  prefixIcon: Icons.directions_car_rounded,
                  controller: _carportController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            // Seksi 3: Dimensi Luas
            SectionCard(
              icon: Icons.square_foot_rounded,
              title: 'Dimensi Luas',
              badge: 'Metric (m\u00B2)',
              children: [
                CustomTextField(
                  label: 'Luas Tanah',
                  hint: 'Contoh: 140',
                  prefixIcon: Icons.crop_landscape_rounded,
                  suffixText: 'm\u00B2',
                  helperText: 'Min. 1 m\u00B2',
                  controller: _landAreaController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Luas Bangunan',
                  hint: 'Contoh: 120',
                  prefixIcon: Icons.home_rounded,
                  suffixText: 'm\u00B2',
                  helperText: 'Akumulasi seluruh lantai',
                  controller: _buildingAreaController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.sm),

            // Tombol CTA
            GradientButton(
              text: _isLoading ? 'Menghitung Estimasi...' : 'Prediksi Harga',
              icon: _isLoading ? null : Icons.auto_awesome_rounded,
              onPressed: _isLoading ? null : () => _handlePredict(),
            ),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  /// Builder dropdown dalam container bergaya input surface.
  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: AppSizes.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.inputSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Row(
                children: [
                  Icon(icon, size: AppSizes.iconMd, color: AppColors.textHint),
                  const SizedBox(width: AppSizes.sm),
                  Text(hint, style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textHint,
                  )),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
              dropdownColor: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              style: AppTypography.inputContent,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(icon, size: AppSizes.iconMd, color: AppColors.primaryBlue),
                    const SizedBox(width: AppSizes.sm),
                    Text(item),
                  ],
                ),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Alias PredictFormScreen agar kompatibel dengan penamaan lama.
typedef PredictFormScreen = PredictFormPage;
