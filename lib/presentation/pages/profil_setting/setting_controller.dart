// ============================================================
// BACKEND LAYER — setting_controller.dart
// Bertanggung jawab atas: load data user, logout, navigasi.
//
// Yang DIHAPUS dari versi lama:
// - SharedPreferences inline di widget
// - Logic pesanan (Dikemas/Dikirim/Selesai/Batal) → D'Kost
//   tidak pakai sistem pengiriman, diganti status booking
// - import panduan.dart (dihapus sesuai kebutuhan D'Kost)
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_helper.dart';

class SettingController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  String userName = 'Pengguna';
  String userEmail = '';

  final VoidCallback onStateChanged;

  SettingController({required this.onStateChanged});

  // ── Init: Load data user ───────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId != null) {
        final user = await UserService.fetchUser(userId);
        if (user != null) {
          userName = user.nama;
          userEmail = user.email;
        }
      }
    } catch (_) {
      // Tetap tampil meski gagal load user
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout(BuildContext context) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      ),
    );

    try {
      await UserService.logout(); // Clear session & hit API logout

      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading

      Navigator.pushReplacementNamed(context, '/welcome');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Berhasil logout'),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terjadi kesalahan saat logout'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── Konfirmasi Logout Dialog ───────────────────────────────
  Future<void> confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade400, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Konfirmasi Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF555555))),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await logout(context);
    }
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToDetailAkun(BuildContext context) {
    Navigator.pushNamed(context, '/detail-akun');
  }

  void goToLupaPassword(BuildContext context) {
    Navigator.pushNamed(context, '/lupa-password');
  }

  void goToPanduan(BuildContext context) {
    Navigator.pushNamed(context, '/panduan');
  }
}