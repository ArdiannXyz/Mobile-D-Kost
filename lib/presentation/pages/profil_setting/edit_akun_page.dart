// ============================================================
// FRONTEND LAYER — edit_profil_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/user_models.dart';
import 'edit_akun_controller.dart';

class EditProfilPage extends StatefulWidget {
  final User user;
  const EditProfilPage({super.key, required this.user});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late final EditProfilController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfilController(
      user: widget.user,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _controller.onWillPop(context);
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1BBA8A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () async {
          final shouldPop = await _controller.onWillPop(context);
          if (shouldPop && context.mounted) Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: const Text(
        'Edit profil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Nama: hanya huruf & spasi, max 50 ────────
                _buildInputField(
                  label: 'Nama',
                  controller: _controller.namaController,
                  hint: 'Masukkan nama lengkap',
                  maxLength: 50,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\p{L}\s]', unicode: true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Email: disabled, tidak bisa diedit ────────
                _buildInputField(
                  label: 'Email',
                  controller: _controller.emailController,
                  hint: 'Email',
                  enabled: false,
                ),
                const SizedBox(height: 20),

                // ── No. Handphone: hanya angka, max 13 ────────
                _buildInputField(
                  label: 'No. Handphone',
                  controller: _controller.noHpController,
                  hint: 'Masukkan nomor handphone',
                  keyboardType: TextInputType.phone,
                  maxLength: 13,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20),

                // ── Alamat: bebas, max 100 ────────────────────
                _buildInputField(
                  label: 'Alamat',
                  controller: _controller.alamatController,
                  hint: 'Masukkan alamat',
                  maxLines: 2,
                  maxLength: 100,
                ),

              ],
            ),
          ),
        ),

        // ── Tombol Simpan sticky di bawah ─────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () => _controller.simpan(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1BBA8A),
                disabledBackgroundColor:
                    const Color(0xFF1BBA8A).withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable Input Field ───────────────────────────────────
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 14,
            color: enabled
                ? const Color(0xFF1A1A2E)
                : const Color(0xFF9E9E9E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B0C3)),
            filled: true,
            fillColor:
                enabled ? Colors.white : const Color(0xFFF5F5F5),
            // Counter disembunyikan — batas tetap aktif via maxLength
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF1BBA8A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}