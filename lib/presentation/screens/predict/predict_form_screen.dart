import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_card.dart';
import 'result_screen.dart';


/// Layar Form Prediksi ML (FR-MOB-02).
/// Form input parameter properti untuk estimasi harga.
/// Referensi: design-system.md § 3A – Struktur Kartu Form Input Properti
class PredictFormScreen extends StatefulWidget {
  const PredictFormScreen({super.key});

  @override
  State<PredictFormScreen> createState() => _PredictFormScreenState();
}

class _PredictFormScreenState extends State<PredictFormScreen> {
  // ── Mock Data Dropdown ─────────────────────────────────────────────────────
  static const _kotaOptions = [
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
    'Jakarta Pusat',
  ];

  static const Map<String, List<String>> _kecamatanMap = {
    'Jakarta Selatan': ['Kebayoran Baru', 'Cilandak', 'Pesanggrahan', 'Jagakarsa', 'Pancoran'],
    'Jakarta Barat': ['Kebon Jeruk', 'Grogol Petamburan', 'Cengkareng', 'Kali Deres', 'Tambora'],
    'Jakarta Timur': ['Matraman', 'Jatinegara', 'Duren Sawit', 'Cakung', 'Cipayung'],
    'Jakarta Utara': ['Kelapa Gading', 'Tanjung Priok', 'Koja', 'Penjaringan', 'Pademangan'],
    'Jakarta Pusat': ['Menteng', 'Tanah Abang', 'Gambir', 'Senen', 'Cempaka Putih'],
  };

  String? _selectedKota;
  String? _selectedKecamatan;

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

            // ── Seksi 1: Wilayah & Lokasi ──────────────────────────────────
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
                  items: _selectedKota != null
                      ? _kecamatanMap[_selectedKota]!
                      : [],
                  icon: Icons.map_rounded,
                  onChanged: _selectedKota != null
                      ? (val) => setState(() => _selectedKecamatan = val)
                      : null,
                ),
              ],
            ),

            // ── Seksi 2: Tata Ruang, Kamar & Garasi ────────────────────────
            SectionCard(
              icon: Icons.grid_view_rounded,
              title: 'Tata Ruang & Fasilitas',
              badge: 'Spesifikasi',
              children: [
                const CustomTextField(
                  label: 'Jumlah Kamar Tidur',
                  hint: 'Contoh: 3',
                  prefixIcon: Icons.bed_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Jumlah Kamar Mandi',
                  hint: 'Contoh: 2',
                  prefixIcon: Icons.shower_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Kapasitas Garasi / Carport',
                  hint: 'Contoh: 1',
                  prefixIcon: Icons.directions_car_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            // ── Seksi 3: Dimensi Luas ──────────────────────────────────────
            SectionCard(
              icon: Icons.square_foot_rounded,
              title: 'Dimensi Luas',
              badge: 'Metric (m²)',
              children: [
                const CustomTextField(
                  label: 'Luas Tanah',
                  hint: 'Contoh: 140',
                  prefixIcon: Icons.crop_landscape_rounded,
                  suffixText: 'm²',
                  helperText: 'Min. 30 m²',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.md),
                const CustomTextField(
                  label: 'Luas Bangunan',
                  hint: 'Contoh: 120',
                  prefixIcon: Icons.home_rounded,
                  suffixText: 'm²',
                  helperText: 'Akumulasi seluruh lantai',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.sm),

            // ── Tombol CTA ─────────────────────────────────────────────────
            GradientButton(
              text: 'Prediksi Harga',
              icon: Icons.auto_awesome_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResultScreen(),
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

