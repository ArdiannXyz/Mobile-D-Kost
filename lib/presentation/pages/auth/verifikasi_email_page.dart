import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_exception.dart';
import 'login_page.dart';

class VerifikasiEmailPage extends StatefulWidget {
  final String email;
  const VerifikasiEmailPage({super.key, required this.email});

  @override
  State<VerifikasiEmailPage> createState() => _VerifikasiEmailPageState();
}

class _VerifikasiEmailPageState extends State<VerifikasiEmailPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 60; // detik cooldown resend
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  Future<void> _verifikasi() async {
    if (_otpValue.length < 6) {
      _showSnackbar('Masukkan 6 digit kode OTP!', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = await UserService.verifikasiEmail(
        email: widget.email,
        otp: _otpValue,
      );
      if (!mounted) return;
      if (data['error'] == false) {
        _showSuccessDialog();
      } else {
        _showSnackbar(data['message'] ?? 'Verifikasi gagal.', isError: true);
      }
    } on ApiException catch (e) {
      if (mounted) _showSnackbar(e.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showSnackbar('Terjadi kesalahan. Coba lagi.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      final data = await UserService.resendOtpRegister(email: widget.email);
      if (!mounted) return;
      if (data['error'] == false) {
        _showSnackbar('Kode OTP baru telah dikirim!');
        _startCountdown();
        // Reset semua kotak OTP
        for (final c in _otpControllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        _showSnackbar(data['message'] ?? 'Gagal mengirim ulang.',
            isError: true);
      }
    } on ApiException catch (e) {
      if (mounted) _showSnackbar(e.message, isError: true);
    } catch (_) {
      if (mounted) _showSnackbar('Gagal mengirim ulang OTP.', isError: true);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSuccessDialog() {
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
                decoration: const BoxDecoration(
                    color: Color(0xFF1BBA8A), shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Email Terverifikasi!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              const Text(
                'Akun anda telah aktif.\nSilakan login untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BBA8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Login Sekarang',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF1BBA8A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verifikasi Email',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Text(
                'Masukkan 6 digit kode yang dikirim ke\n${widget.email}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 24),

              // ── Tombol Kirim Ulang ──────────────────────────
              Center(
                child: _isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF1BBA8A), strokeWidth: 2))
                    : _countdown > 0
                        ? Text(
                            'Kirim ulang kode dalam $_countdown detik',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF9E9E9E)),
                          )
                        : GestureDetector(
                            onTap: _resendOtp,
                            child: const Text(
                              'Kirim Ulang Kode OTP',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1BBA8A),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF1BBA8A),
                              ),
                            ),
                          ),
              ),
              // ───────────────────────────────────────────────

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifikasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BBA8A),
                    disabledBackgroundColor:
                        const Color(0xFF1BBA8A).withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Verifikasi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1BBA8A), width: 1.5)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
          if (index == 5 && value.isNotEmpty) _verifikasi();
        },
      ),
    );
  }
}
