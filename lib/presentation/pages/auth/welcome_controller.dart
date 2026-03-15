// ============================================================
// BACKEND LAYER — welcome_controller.dart
// Bertanggung jawab atas: navigasi logic, state, dan
// interaksi dengan service (jika ada).
// UI tidak boleh ada di sini.
// ============================================================

import 'package:flutter/material.dart';

class WelcomeController {
  // Navigasi ke halaman Login
  void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  // Navigasi ke halaman Register
  void goToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  // Cek apakah user sudah pernah login (contoh: dari SharedPreferences)
  // Bisa dikembangkan untuk auto-redirect jika sudah ada sesi aktif
  Future<bool> isUserLoggedIn() async {
    // TODO: Implementasi cek token dari SharedPreferences / SecureStorage
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('token') != null;
    return false;
  }

  // Inisialisasi saat halaman pertama kali dibuka
  // Bisa digunakan untuk redirect otomatis jika sudah login
  Future<void> init(BuildContext context) async {
    final loggedIn = await isUserLoggedIn();
    if (loggedIn && context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}