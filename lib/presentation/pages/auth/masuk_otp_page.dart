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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in _digitControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _controller.otpController.text =
        _digitControllers.map((c) => c.text).join();
  }

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button pojok atas kiri
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: GestureDetector(
                onTap: () => _controller.goBack(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1A1A2E),
                    size: 16,
                  ),
                ),
              ),
            ),

            // Konten
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Masukkan Kode OTP',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9E9E9E),
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Kode dikirim ke '),
                                      TextSpan(
                                        text: _controller.email.isEmpty
                                            ? 'email Anda'
                                            : _controller.email,
                                        style: const TextStyle(
                                          color: Color(0xFF9E9E9E),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              color: Color(0xFF1BBA8A),
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // 6 kotak OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 48,
                            height: 56,
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (event) =>
                                  _onKeyEvent(index, event),
                              child: TextField(
                                controller: _digitControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A2E),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (value) =>
                                    _onDigitChanged(index, value),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 233, 233, 233),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE8E8E8)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE8E8E8)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1BBA8A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Kirim ulang
                      Center(
                        child: TextButton(
                          onPressed: () => _controller.resendOtp(context),
                          child: const Text(
                            'Kirim ulang kode OTP',
                            style: TextStyle(
                              color: Color(0xFF1BBA8A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Verifikasi
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading
                              ? null
                              : () => _controller.submitOtp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BBA8A),
                            disabledBackgroundColor:
                                const Color(0xFF1BBA8A).withValues(alpha: 0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: _controller.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Verifikasi OTP',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}