import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';

class MasukOtpController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;

  // ── Cooldown Timer ─────────────────────────────────────────
  int cooldownSeconds = 0;
  Timer? _cooldownTimer;

  // ── Text Controller ────────────────────────────────────────
  final TextEditingController otpController = TextEditingController();

  String email = '';

  final VoidCallback onStateChanged;
  MasukOtpController({required this.onStateChanged});

  // ── Getter: apakah sedang cooldown ────────────────────────
  bool get isCooldown => cooldownSeconds > 0;

  // ── Init ───────────────────────────────────────────────────
  void init(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      email = args['email'] ?? '';
    }
    // Langsung mulai cooldown 60 detik saat halaman dibuka,
    // karena OTP sudah dikirim sebelum masuk halaman ini.
    _startCooldown();
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    otpController.dispose();
    _cooldownTimer?.cancel();
  }

  // ── Mulai countdown 60 detik ───────────────────────────────
  void _startCooldown() {
    cooldownSeconds = 60;
    onStateChanged();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      cooldownSeconds--;
      onStateChanged();
      if (cooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  // ── Validasi OTP ───────────────────────────────────────────
  String? validate() {
    final otp = otpController.text.trim();
    if (otp.isEmpty) return 'Kode OTP harus diisi.';
    if (otp.length != 6) return 'Kode OTP harus 6 digit.';
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Kode OTP hanya boleh berisi angka.';
    }
    return null;
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
    if (email.isEmpty || isCooldown) return;

    try {
      final result = await UserService.lupaPassword(email);
      if (!context.mounted) return;

      if (result['error'] == false) {
        _startCooldown();
        _showSuccessSnackbar(context, 'Kode OTP baru dikirim ke $email');
      } else {
        _showErrorSnackbar(
          context,
          result['message'] ?? 'Gagal mengirim ulang OTP.',
        );
        if (!isCooldown) _startCooldown();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Terjadi kesalahan. Coba lagi nanti.');
      }
    }
  }

  // ── Navigasi Kembali ───────────────────────────────────────
  void goBack(BuildContext context) => Navigator.pop(context);

  // ── Helper Snackbar ────────────────────────────────────────
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
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
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}