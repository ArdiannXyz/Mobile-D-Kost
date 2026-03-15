// ============================================================
// BACKEND LAYER — login_controller.dart
// Bertanggung jawab atas: validasi, pemanggilan UserService,
// navigasi, dan state management.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';
import 'register_page.dart';
import 'lupa_password_page.dart';
import '../home/home_page.dart';

class LoginController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool obscurePassword = true;

  // ── Text Controllers ───────────────────────────────────────
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  LoginController({required this.onStateChanged});

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // ── Toggle Password Visibility ─────────────────────────────
  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    onStateChanged();
  }

  // ── Validasi Input ─────────────────────────────────────────
  String? validate() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      return 'Email dan password harus diisi!';
    }

    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(emailController.text.trim())) {
      return 'Masukkan email yang valid!';
    }

    return null; // null = valid
  }

  // ── Login User ─────────────────────────────────────────────
  Future<void> loginUser(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      final data = await UserService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;

      if (data['error'] == false) {
        _showSuccessDialog(context);
      } else {
        _showErrorSnackbar(context, data['message'] ?? 'Login gagal.');
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

  // ── Navigasi ───────────────────────────────────────────────
  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void goToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LupaPasswordPage()),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  // ── Dialog & Snackbar ──────────────────────────────────────
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoginSuccessDialog(
        onContinue: () {
          Navigator.of(context).pop();
          _goToHome(context);
        },
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

// ── Dialog Widget (UI kecil milik controller) ──────────────────
// Diletakkan di sini karena hanya dipakai oleh controller ini,
// bukan reusable di tempat lain.
class _LoginSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;
  const _LoginSuccessDialog({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1A1A2E),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon centang
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login Berhasil!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selamat datang kembali!\nAnda akan diarahkan ke halaman utama.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFFB0B0C3)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
