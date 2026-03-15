// ============================================================
// BACKEND LAYER — lupa_password_controller.dart
// Bertanggung jawab atas: validasi email, pemanggilan
// UserService.lupaPassword, navigasi ke OTP page.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';

class LupaPasswordController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;

  // ── Text Controller ────────────────────────────────────────
  final TextEditingController emailController = TextEditingController();

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  LupaPasswordController({required this.onStateChanged});

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    emailController.dispose();
  }

  // ── Validasi Email ─────────────────────────────────────────
  String? validate() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return 'Silakan masukkan email Anda.';
    }

    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(email)) {
      return 'Masukkan email yang valid.';
    }

    return null; // null = valid
  }

  // ── Submit Reset Password ──────────────────────────────────
  Future<void> submitReset(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final email = emailController.text.trim();
      final result = await UserService.lupaPassword(email);

      if (!context.mounted) return;

      if (result['error'] == false) {
        _showSuccessSnackbar(context, 'Kode OTP dikirim ke $email');
        // Kirim email sebagai argument ke halaman OTP
        Navigator.pushNamed(
          context,
          '/masuk-otp',
          arguments: {'email': email},
        );
      } else {
        _showErrorSnackbar(
          context,
          result['message'] ?? 'Gagal mengirim kode OTP.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Navigasi Kembali ───────────────────────────────────────
  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // ── Helper Snackbar ────────────────────────────────────────
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}