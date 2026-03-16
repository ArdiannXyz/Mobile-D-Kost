import 'package:flutter/material.dart';
import 'ganti_password_controller.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({super.key});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  late final GantiPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GantiPasswordController(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Buat Password Baru',
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
                                      const TextSpan(
                                          text: 'Buat password baru untuk\n'),
                                      TextSpan(
                                        text: _controller.email.isEmpty
                                            ? 'akun Anda'
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
                              Icons.lock_open_rounded,
                              color: Color(0xFF2ECC71),
                              size: 30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Password Baru
                      _buildPasswordField(
                        label: 'Password Baru',
                        hint: 'Masukkan password baru',
                        controller: _controller.newPasswordController,
                        isObscure: _controller.obscureNewPassword,
                        onToggle: _controller.toggleObscureNewPassword,
                      ),

                      const SizedBox(height: 16),

                      // Konfirmasi Password
                      _buildPasswordField(
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password baru',
                        controller: _controller.confirmPasswordController,
                        isObscure: _controller.obscureConfirmPassword,
                        onToggle: _controller.toggleObscureConfirmPassword,
                      ),

                      const SizedBox(height: 12),

                      // Password rules
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Syarat password:',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildRule('Minimal 6 karakter'),
                            _buildRule('Password dan konfirmasi harus sama'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _controller.isLoading
                              ? null
                              : () => _controller.gantiPassword(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            disabledBackgroundColor: const Color(0xFF2ECC71)
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
                                  'Simpan Password',
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

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFFB0B0C3), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFB0B0C3),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF9E9E9E),
                size: 20,
              ),
              onPressed: onToggle,
            ),
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
              borderSide:
                  const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF2ECC71),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}