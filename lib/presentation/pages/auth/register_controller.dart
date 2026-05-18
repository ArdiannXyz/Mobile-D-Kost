import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';
import 'login_page.dart';
import 'verifikasi_email_page.dart';

class RegisterController {
  bool isLoading = false;
  bool obscurePassword = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  final VoidCallback onStateChanged;
  RegisterController({required this.onStateChanged});

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    alamatController.dispose();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    onStateChanged();
  }

  String? validate() {
    final nama = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (nama.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      return 'Semua kolom harus diisi!';
    }

    // ── Nama: hanya huruf & spasi ──────────────────────────
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(nama)) {
      return 'Nama hanya boleh berisi huruf dan spasi.';
    }

    // ── Email ──────────────────────────────────────────────
    if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
        .hasMatch(email)) {
      return 'Masukkan email yang valid!';
    }

    // ── Password: minimal 8 karakter ──────────────────────
    if (password.length < 8) {
      return 'Password harus minimal 8 karakter!';
    }

    // ── Password: harus ada huruf besar ───────────────────
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 huruf besar!';
    }

    // ── Password: harus ada simbol ────────────────────────
    if (!RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 simbol (contoh: @, #, !)';
    }

    return null;
  }

  Future<void> registerUser(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) {
      _showErrorSnackbar(context, errorMsg);
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
        alamat: alamatController.text.trim(),
      );

      if (!context.mounted) return;

      if (data['error'] == false) {
        _goToVerifikasiEmail(context, emailController.text.trim());
      } else {
        _showErrorSnackbar(
          context,
          data['message'] ?? 'Registrasi gagal. Coba lagi.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Navigasi ───────────────────────────────────────────────

  void goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

  void _goToVerifikasiEmail(BuildContext context, String email) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifikasiEmailPage(email: email),
        ),
      );

  // ── Snackbar Error ─────────────────────────────────────────

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
