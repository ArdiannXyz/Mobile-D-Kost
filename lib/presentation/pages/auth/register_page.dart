import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // ── Nama: hanya huruf & spasi, max 50 ─────
                      _buildInputField(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        controller: _controller.nameController,
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\p{L}\s]', unicode: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Email: max 50 ──────────────────────────
                      _buildInputField(
                        label: 'Email',
                        hint: 'Masukkan email anda',
                        controller: _controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                      ),
                      const SizedBox(height: 14),

                      // ── No. HP: hanya angka, max 13 ───────────
                      _buildInputField(
                        label: 'No. HP',
                        hint: 'Masukkan nomor handphone anda',
                        controller: _controller.phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 13,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Alamat: bebas, max 100 ─────────────────
                      _buildInputField(
                        label: 'Alamat',
                        hint: 'Masukkan alamat anda',
                        controller: _controller.alamatController,
                        maxLines: 2,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 14),

                      // ── Password: max 50 ───────────────────────
                      _buildPasswordField(
                        label: 'Password',
                        hint: 'Masukkan password anda',
                        controller: _controller.passwordController,
                        isObscure: _controller.obscurePassword,
                        onToggle: _controller.toggleObscurePassword,
                        maxLength: 50,
                      ),
                      const SizedBox(height: 10),

                      _buildPasswordRules(),
                      const SizedBox(height: 24),
                      _buildRegisterButton(),
                      const SizedBox(height: 16),
                      _buildLoginLink(),
                      const SizedBox(height: 16),
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

  // ── Header ─────────────────────────────────────────────────
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
        Image.asset(
          'assets/images/dkos_1.png',
          width: 64,
          height: 64,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF1BBA8A),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'DK',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password Rules Info ────────────────────────────────────
  Widget _buildPasswordRules() {
    return Container(
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
          _buildRule('Terdapat minimal 1 huruf kapital'),
          _buildRule('Minimal 8 karakter'),
          _buildRule('Mengandung minimal 1 simbol (contoh: @, #, !, _)'),
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
            color: Color(0xFF1BBA8A),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Field ────────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  // ── Password Field ─────────────────────────────────────────
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    int? maxLength,
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
          maxLength: maxLength,
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

  // ── Register Button ────────────────────────────────────────
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.registerUser(context),
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
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ── Login Link ─────────────────────────────────────────────
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
                  color: Color(0xFF1BBA8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Decoration ───────────────────────────────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B0C3), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      // Counter disembunyikan — batas tetap aktif via maxLength
      counterText: '',
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}