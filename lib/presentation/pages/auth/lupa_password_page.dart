import 'package:flutter/material.dart';
import 'lupa_password_controller.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  late final LupaPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LupaPasswordController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

            // Konten tengah
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Masukkan email terdaftar untuk mendapat kode OTP.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9E9E9E),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: Color(0xFF1BBA8A),
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Email field
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            color: Color(0xFF1A1A2E), fontSize: 14),
                        decoration: _inputDecoration(
                          'Masukkan email anda',
                          prefixIcon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Info text
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFFB0B0C3), size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Kode OTP akan dikirim ke email Anda.',
                            style: TextStyle(
                                color: Color(0xFFB0B0C3), fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading
                              ? null
                              : () => _controller.submitReset(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BBA8A),
                            disabledBackgroundColor: const Color(0xFF1BBA8A)
                                .withValues(alpha: 0.5),
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
                                  'Kirim Kode OTP',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Link kembali ke login
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ingat password? ',
                              style: TextStyle(
                                  color: Color(0xFF9E9E9E), fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () => _controller.goBack(context),
                              child: const Text(
                                'Masuk sekarang!',
                                style: TextStyle(
                                  color: Color(0xFF1BBA8A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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

  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B0C3), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFFB0B0C3), size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1BBA8A), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}