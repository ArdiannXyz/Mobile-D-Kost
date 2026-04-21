import 'package:flutter/material.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 36),
                _buildInputField(
                  label: 'Email',
                  hint: 'Masukkan email anda',
                  controller: _controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 4),
                _buildForgotPasswordLink(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Kami merindukan anda',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
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
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller.passwordController,
          obscureText: _controller.obscurePassword,
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: _inputDecoration('Masukkan password anda').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _controller.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF9E9E9E),
                size: 20,
              ),
              onPressed: _controller.toggleObscurePassword,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _controller.goToForgotPassword(context),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Lupa Password Kamu?',
          style: TextStyle(
            color: Color(0xFF1BBA8A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading
            ? null
            : () => _controller.loginUser(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1BBA8A),
          disabledBackgroundColor: const Color(0xFF1BBA8A).withValues(alpha: 0.5),
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
                'Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tidak punya akun? ',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          GestureDetector(
            onTap: () => _controller.goToRegister(context),
            child: const Text(
              'Daftar sekarang!',
              style: TextStyle(
                color: Color(0xFF1BBA8A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        borderSide: const BorderSide(color: Color(0xFF1BBA8A), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}