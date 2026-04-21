import 'package:flutter/material.dart';
import 'welcome_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final WelcomeController _controller = WelcomeController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Robot PNG langsung tanpa background ────────
              Image.asset(
                'assets/images/robot.png',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFF1BBA8A),
                  size: 100,
                ),
              ),

              const Spacer(flex: 1),

              // ── Judul ──────────────────────────────────────
              const Text(
                "D'Kost",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtitle ───────────────────────────────────
              const Text(
                'Carilah tempat dimana kamu dapat\npulang dan beristirahat dengan nyaman',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 2),

              // ── Tombol ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _WelcomeButton(
                      label: 'Masuk',
                      onPressed: () => _controller.goToLogin(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _WelcomeButton(
                      label: 'Daftar',
                      onPressed: () => _controller.goToRegister(context),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _WelcomeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1BBA8A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}