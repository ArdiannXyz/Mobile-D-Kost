import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/midtrans_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/helper/api_exception.dart';
import 'register_page.dart';
import 'lupa_password_page.dart';
import '../home/home_page.dart';
import '../../../data/services/notifikasi_api_service.dart';
import '../../../data/services/fcm_setup.dart';

class LoginController {
  bool isLoading = false;
  bool obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final VoidCallback onStateChanged;

  LoginController({required this.onStateChanged});

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    onStateChanged();
  }

  String? validate() {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      return 'Email dan password harus diisi!';
    }
    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(emailController.text.trim())) {
      return 'Masukkan email yang valid!';
    }
    return null;
  }

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
        // ✅ Cek role dari data['user']['role']
        final String role = data['user']?['role'] ?? '';

        if (role == 'admin') {
          // ❌ Admin tidak diizinkan masuk ke aplikasi mobile
          _showAdminDeniedDialog(context);
          return;
        }

        // // ✅ Hanya penyewa yang boleh lanjut
        // final token = await ApiHelper.getToken();
        // if (token != null) {
        //   MidtransService.setToken(token);
          
        // }
        //   // ── Simpan token untuk API notifikasi ──────────
        //   NotifikasiApiService.authToken = data['token'] ?? '';
        //   debugPrint('Token dipakai: $token');

        //   // ── Init FCM ───────────────────────────────────
        //   debugPrint('Memanggil initFcm...');
        //   debugPrint('Token yang akan dipakai FCM: ${NotifikasiApiService.authToken}');
        //   await FcmSetup.initFcm();
        //   debugPrint('initFcm selesai');

        // 🔥 AMBIL TOKEN DARI LOGIN (SUMBER UTAMA)
      final token = data['token'];

      if (token == null || token.isEmpty) {
        _showErrorSnackbar(context, 'Token tidak valid');
        return;
      }

      // 🔥 SIMPAN SESSION DI SINI
        await ApiHelper.saveSession(
        userId: data['user']['id_user'],
        role: role,
        token: token,
      );

      // 🔥 pakai token ke service lain
        MidtransService.setToken(token);
        NotifikasiApiService.authToken = token;

        debugPrint('Token dipakai: $token');

      // 🔥 INIT FCM SETELAH TOKEN SIAP
      debugPrint('Memanggil initFcm...');
      await FcmSetup.initFcm();
      debugPrint('initFcm selesai');

        if (!context.mounted) return;
        _showSuccessDialog(context);
      } else {
        _showErrorSnackbar(context, data['message'] ?? 'Login gagal.');
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackbar(context, e.message);
    } catch (_) {
      if (context.mounted)
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void goToRegister(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));

  void goToForgotPassword(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LupaPasswordPage()));

  void _goToHome(BuildContext context) =>
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));

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

  void _showAdminDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: Colors.red.shade600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Akses Ditolak',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Akun admin tidak dapat masuk\nke aplikasi mobile ini.\nGunakan dashboard web untuk admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

// ── Dialog Login Berhasil ──────────────────────────────────────
class _LoginSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;
  const _LoginSuccessDialog({required this.onContinue});

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
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF1BBA8A),
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
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selamat datang kembali!\nAnda akan diarahkan ke halaman utama.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBA8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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