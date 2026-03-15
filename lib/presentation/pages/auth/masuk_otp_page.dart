// ============================================================
// FRONTEND LAYER — masuk_otp_page.dart
// Bertanggung jawab atas: tampilan UI saja.
// Menggunakan 6 kotak input OTP terpisah untuk UX lebih baik.
// Semua logic ada di controller.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'masuk_otp_controller.dart';

class MasukOtpPage extends StatefulWidget {
  const MasukOtpPage({super.key});

  @override
  State<MasukOtpPage> createState() => _MasukOtpPageState();
}

class _MasukOtpPageState extends State<MasukOtpPage> {
  late final MasukOtpController _controller;

  // 6 controller & focusNode terpisah untuk setiap digit OTP
  final List<TextEditingController> _digitControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _controller = MasukOtpController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );

    // Init email dari route arguments setelah frame pertama render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      setState(() {}); // Refresh untuk tampilkan email
    });
  }

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  // Gabungkan 6 digit menjadi satu string ke controller utama
  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Auto-focus ke kotak berikutnya
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    // Update controller utama dengan gabungan 6 digit
    _controller.otpController.text =
        _digitControllers.map((c) => c.text).join();
  }

  // Handle backspace untuk kembali ke kotak sebelumnya
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildBackButton(),
              const Spacer(flex: 1),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildOtpBoxes(),
              const SizedBox(height: 12),
              _buildResendButton(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget Builders (UI only) ──────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => _controller.goBack(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A4A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon OTP
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF2ECC71),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Masukkan Kode OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        // Tampilkan email tujuan OTP
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0C3),
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Kode dikirim ke\n'),
              TextSpan(
                text: _controller.email.isEmpty
                    ? 'email Anda'
                    : _controller.email,
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(index, event),
            child: TextField(
              controller: _digitControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => _onDigitChanged(index, value),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFF2A2A4A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2ECC71),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: TextButton(
        onPressed: () => _controller.resendOtp(context),
        child: const Text(
          'Kirim ulang kode OTP',
          style: TextStyle(
            color: Color(0xFF2ECC71),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.submitOtp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          disabledBackgroundColor: const Color(0xFF2ECC71).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: _controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Verifikasi OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}