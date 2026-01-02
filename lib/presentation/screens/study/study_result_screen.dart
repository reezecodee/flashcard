import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StudyResultScreen extends StatelessWidget {
  const StudyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppColors.good,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sesi Selesai',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tidak ada kartu lagi untuk saat ini.\nIstirahat dulu ya!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                // kembali ke halaman home, hapus semua history navigasi belajar
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Kembali ke Menu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
