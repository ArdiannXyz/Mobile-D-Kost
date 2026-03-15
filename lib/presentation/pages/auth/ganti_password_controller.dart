// ============================================================
// BACKEND LAYER — ganti_password_controller.dart
// Bertanggung jawab atas: ambil email dari route args,
// validasi password, pemanggilan UserService.gantiPassword,
// dan navigasi ke halaman login setelah berhasil.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';
class GantiPasswordController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  // ── Text Controllers ───────────────────────────────────────
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Email diterima dari route arguments (dari masuk_otp_page)
  String email = '';

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  GantiPasswordController({required this.onStateChanged});

  // ── Init: Ambil email dari route arguments ─────────────────
  void init(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      email = args['email'] ?? '';
    }
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // ── Toggle Visibility ──────────────────────────────────────
  void toggleObscureNewPassword() {
    obscureNewPassword = !obscureNewPassword;
    onStateChanged();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    onStateChanged();
  }

  // ── Validasi ───────────────────────────────────────────────
  String? validate() {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      return 'Semua kolom harus diisi.';
    }

    if (newPass.length < 6) {
      return 'Password baru harus minimal 6 karakter.';
    }

    if (newPass != confirmPass) {
      return 'Password dan konfirmasi password tidak cocok.';
    }

    return null; // null = valid
  }

  // ── Ganti Password ─────────────────────────────────────────
  Future<void> gantiPassword(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final result = await UserService.gantiPassword(
        email: email,
        password: newPasswordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      if (!context.mounted) return;

      if (result['error'] == false) {
        _showSuccessSnackbar(
          context,
          result['message'] ?? 'Password berhasil diubah.',
        );
        // Delay 2 detik lalu arahkan ke halaman login, hapus semua route
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } else {
        _showErrorSnackbar(
          context,
          result['message'] ?? 'Gagal mengubah password.',
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
        duration: const Duration(seconds: 2),
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
