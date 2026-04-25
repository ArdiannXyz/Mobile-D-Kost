// ============================================================
// BACKEND LAYER — masuk_otp_controller.dart
// Bertanggung jawab atas: ambil argument email dari route,
// validasi OTP, pemanggilan UserService.cekOtp, navigasi.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';

class MasukOtpController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;

  // ── Text Controller ────────────────────────────────────────
  final TextEditingController otpController = TextEditingController();

  // Email diterima dari route arguments (dari lupa_password_page)
  String email = '';

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  MasukOtpController({required this.onStateChanged});

  // ── Init: Ambil email dari route arguments ─────────────────
  void init(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      email = args['email'] ?? '';
    }
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    otpController.dispose();
  }

  // ── Validasi OTP ───────────────────────────────────────────
  String? validate() {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      return 'Kode OTP harus diisi.';
    }

    if (otp.length != 6) {
      return 'Kode OTP harus 6 digit.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Kode OTP hanya boleh berisi angka.';
    }

    return null; // null = valid
  }

  // ── Submit OTP ─────────────────────────────────────────────
  Future<void> submitOtp(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      otpController.clear();
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final result = await UserService.cekOtp(
        email: email,
        otp: otpController.text.trim(),
      );

      if (!context.mounted) return;

      if (result['error'] == false) {
        // OTP valid → navigasi ke halaman ganti password
        Navigator.pushNamed(
          context,
          '/ganti-password',
          arguments: {'email': email},
        );
      } else {
        _showErrorSnackbar(
          context,
          result['message'] ?? 'Kode OTP tidak valid.',
        );
        otpController.clear();
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, e.message);
        otpController.clear();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
        otpController.clear();
      }
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Kirim Ulang OTP ────────────────────────────────────────
  Future<void> resendOtp(BuildContext context) async {
    if (email.isEmpty) return;

    try {
      final result = await UserService.lupaPassword(email);
      if (!context.mounted) return;

      if (result['error'] == false) {
        _showSuccessSnackbar(context, 'Kode OTP baru dikirim ke $email');
      } else {
        _showErrorSnackbar(
          context,
          result['message'] ?? 'Gagal mengirim ulang OTP.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
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
        backgroundColor: const Color(0xFF1BBA8A),
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
