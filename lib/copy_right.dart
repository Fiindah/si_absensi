import 'package:flutter/material.dart';

/// Widget yang menampilkan informasi hak cipta aplikasi.
/// Tahun hak cipta akan otomatis diperbarui ke tahun saat ini.
class CopyrightWidget extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;
  final String appName; // Nama aplikasi Anda
  final String companyName; // Nama perusahaan/pengembang

  const CopyrightWidget({
    super.key,
    this.textColor,
    this.fontSize,
    this.appName = 'Si Absensi', // Nilai default jika tidak disediakan
    this.companyName = 'Endah F N', // Nilai default jika tidak disediakan
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year; // Mendapatkan tahun saat ini
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          ' $companyName. © $currentYear  $appName.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? Colors.grey[600], // Warna teks default
            fontSize: fontSize ?? 12.0, // Ukuran font default
          ),
        ),
      ),
    );
  }
}
