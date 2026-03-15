// ============================================================
// BACKEND LAYER — register_controller.dart
// Bertanggung jawab atas: validasi input, pemanggilan service,
// navigasi, dan state management.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import 'login_page.dart';

class RegisterController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ── Text Controllers ───────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  RegisterController({required this.onStateChanged});

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // ── Toggle Password Visibility ─────────────────────────────
  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    onStateChanged();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    onStateChanged();
  }

  // ── Validasi Input ─────────────────────────────────────────
  String? validate() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      return 'Semua kolom harus diisi!';
    }

    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(emailController.text)) {
      return 'Masukkan email yang valid!';
    }

    if (passwordController.text.length < 6) {
      return 'Password harus minimal 6 karakter!';
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Password dan konfirmasi password tidak cocok!';
    }

    return null; // null = valid, tidak ada error
  }

  // ── Register User (memanggil UserService) ──────────────────
  Future<void> registerUser(BuildContext context) async {
    // Jalankan validasi dulu
    final errorMsg = validate();
    if (errorMsg != null) {
      _showSnackbar(context, errorMsg);
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final data = await UserService.registerUser(
        nama: nameController.text.trim(),
        email: emailController.text.trim(),
        noHp: phoneController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;

      if (data['error'] == false) {
        _showSuccessDialog(context);
      } else {
        _showSnackbar(context, 'Registrasi gagal: ${data['message']}');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Navigasi ke Login ──────────────────────────────────────
  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ── Helper: Snackbar ───────────────────────────────────────
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ── Helper: Dialog Sukses ──────────────────────────────────
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Registrasi Berhasil!'),
        content: const Text('Akun Anda telah berhasil dibuat. Silakan login.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
