import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import 'login_page.dart';

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
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return 'Semua kolom harus diisi!';
    }
    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(emailController.text)) {
      return 'Masukkan email yang valid!';
    }
    if (passwordController.text.length < 6) {
      return 'Password harus minimal 6 karakter!';
    }
    return null;
  }

  Future<void> registerUser(BuildContext context) async {
    final errorMsg = validate();
    if (errorMsg != null) { _showErrorSnackbar(context, errorMsg); return; }

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
        _showSuccessDialog(context);
      } else {
        _showErrorSnackbar(context, 'Registrasi gagal: ${data['message']}');
      }
    } catch (_) {
      if (context.mounted) _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void goToLogin(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));

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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RegisterSuccessDialog(
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginPage()));
        },
      ),
    );
  }
}

class _RegisterSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;
  const _RegisterSuccessDialog({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFF1BBA8A), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Registrasi Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            const Text('Akun Anda telah berhasil dibuat.\nSilakan login untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBA8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Login Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}