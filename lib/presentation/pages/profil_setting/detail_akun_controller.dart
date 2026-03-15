// ============================================================
// BACKEND LAYER — detail_akun_controller.dart
// Bertanggung jawab atas: load data user, mask email,
// navigasi ke edit profil.
//
// Yang DIHAPUS dari versi lama:
// - Timer auto-refresh 30 detik → tidak perlu untuk profil
// - SharedPreferences inline di widget
// - print("User belum login") → diganti proper handling
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/user_models.dart';

class DetailAkunController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  String? errorMessage;
  User? user;

  final VoidCallback onStateChanged;

  DetailAkunController({required this.onStateChanged});

  // ── Load Data User ─────────────────────────────────────────
  Future<void> loadUser() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();
      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan. Silakan login ulang.';
        return;
      }

      user = await UserService.fetchUser(userId);
      if (user == null) {
        errorMessage = 'Data pengguna tidak ditemukan.';
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat data akun.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Mask Email ─────────────────────────────────────────────
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length < 2) return email;
    final name = parts[0];
    if (name.length <= 4) return email;
    return '${name.substring(0, 4)}*****@${parts[1]}';
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToEditProfil(BuildContext context) {
    if (user == null) return;
    Navigator.pushNamed(
      context,
      '/edit-profil',
      arguments: {'user': user},
    ).then((_) => loadUser()); // Refresh setelah kembali dari edit
  }

  void goBack(BuildContext context) => Navigator.pop(context);
}