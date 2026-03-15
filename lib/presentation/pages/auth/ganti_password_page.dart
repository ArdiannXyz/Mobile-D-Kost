// ============================================================
// FRONTEND LAYER — ganti_password_page.dart
// Bertanggung jawab atas: tampilan UI saja.
// Semua logic (validasi, API call, navigasi) ada di controller.
// ============================================================

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
              const SizedBox(height: 32),
              _buildPasswordField(
                label: 'Password Baru',
                hint: 'Masukkan password baru',
                controller: _controller.newPasswordController,
                isObscure: _controller.obscureNewPassword,
                onToggle: _controller.toggleObscureNewPassword,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password baru',
                controller: _controller.confirmPasswordController,
                isObscure: _controller.obscureConfirmPassword,
                onToggle: _controller.toggleObscureConfirmPassword,
              ),
              const SizedBox(height: 12),
              _buildPasswordRules(),
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
        // Icon kunci buka
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            color: Color(0xFF2ECC71),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Buat Password Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        // Tampilkan email yang sedang di-reset
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0C3),
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Buat password baru untuk\n'),
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
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A4A),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2ECC71),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Syarat password sebagai visual reminder untuk user
  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Syarat password:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _buildRule('Minimal 6 karakter'),
          _buildRule('Password dan konfirmasi harus sama'),
        ],
      ),
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
              color: Color(0xFFB0B0C3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.gantiPassword(context),
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
                'Simpan Password',
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