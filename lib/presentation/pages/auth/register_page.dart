import 'package:flutter/material.dart';
import 'register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(onStateChanged: () {
      if (mounted) setState(() {});
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
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildInputField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _controller.nameController,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Email',
                  hint: 'Masukkan email anda',
                  controller: _controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'No. HP',
                  hint: 'Masukkan nomor handphone anda',
                  controller: _controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  label: 'Password',
                  hint: 'Masukkan password anda',
                  controller: _controller.passwordController,
                  isObscure: _controller.obscurePassword,
                  onToggle: _controller.toggleObscurePassword,
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password anda',
                  controller: _controller.confirmPasswordController,
                  isObscure: _controller.obscureConfirmPassword,
                  onToggle: _controller.toggleObscureConfirmPassword,
                ),
                const SizedBox(height: 28),
                _buildRegisterButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            "Daftarkan akun\nanda",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        // Logo dari asset — konsisten dengan login
        Image.asset(
          'assets/images/dkos 1.png',
          width: 64,
          height: 64,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF2ECC71),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'DK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Input Field ───────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  // ── Password Field ────────────────────────────────────────
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
          decoration: _inputDecoration(hint).copyWith(
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
          ),
        ),
      ],
    );
  }

  // ── Tombol Daftar ─────────────────────────────────────────
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.registerUser(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          disabledBackgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.5),
          foregroundColor: Colors.white,
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
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Daftar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ── Link Login ────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah punya akun? ',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          GestureDetector(
            onTap: () => _controller.goToLogin(context),
            child: const Text(
              'Masuk sekarang!',
              style: TextStyle(
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Decoration ──────────────────────────────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B0C3), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
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
        borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}