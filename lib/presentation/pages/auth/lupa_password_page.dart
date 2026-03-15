// ============================================================
// FRONTEND LAYER — lupa_password_page.dart
// Bertanggung jawab atas: tampilan UI saja.
// Semua logic (validasi, API call, navigasi) ada di controller.
// ============================================================

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
              _buildEmailField(),
              const SizedBox(height: 12),
              _buildInfoText(),
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
        // Icon kunci
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Color(0xFF2ECC71),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan email yang terdaftar,\nkami akan kirimkan kode OTP.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFB0B0C3),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan email anda',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A4A),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.white38,
              size: 20,
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

  Widget _buildInfoText() {
    return Row(
      children: [
        const Icon(
          Icons.info_outline,
          color: Color(0xFFB0B0C3),
          size: 14,
        ),
        const SizedBox(width: 6),
        const Text(
          'Kode OTP akan dikirim ke email Anda.',
          style: TextStyle(
            color: Color(0xFFB0B0C3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.submitReset(context),
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
                'Kirim Kode OTP',
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