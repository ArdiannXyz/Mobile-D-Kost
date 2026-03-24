// ============================================================
// FRONTEND LAYER — detail_akun_page.dart
// Sesuai Figma: AppBar hijau, avatar bulat dengan background
// hijau muda, card putih rounded berisi info akun (nama,
// email masked, no hp, alamat), tombol "Edit Profil" hijau.
// ============================================================

import 'package:flutter/material.dart';
import 'detail_akun_controller.dart';

class DetailAkunPage extends StatefulWidget {
  const DetailAkunPage({super.key});

  @override
  State<DetailAkunPage> createState() => _DetailAkunPageState();
}

class _DetailAkunPageState extends State<DetailAkunPage> {
  late final DetailAkunController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DetailAkunController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ── AppBar hijau ──────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2ECC71),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => _controller.goBack(context),
      ),
      centerTitle: true,
      title: const Text(
        'Detail Informasi Akun',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      );
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined,
                  size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _controller.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ────────────────────────────────────────
          Center(child: _buildAvatar()),

          const SizedBox(height: 28),

          // ── Header row: "Informasi Profil" + "Edit Profil" ─
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Informasi Profil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => _controller.goToEditProfil(context),
                child: const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Card Info ─────────────────────────────────────
          Column(
            children: [
              _buildInfoCard(
                icon: Icons.person_outline,
                value: user.nama,
              ),
              _buildInfoCard(
                icon: Icons.email_outlined,
                value: _controller.maskEmail(user.email),
              ),
              _buildInfoCard(
                icon: Icons.phone_outlined,
                value: user.noHp.isNotEmpty ? user.noHp : '-',
              ),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                value: user.alamat != null && user.alamat!.isNotEmpty
                    ? user.alamat!
                    : '-',
              ),
            ],
          ),
        ],
      ),
    );
  }

          Widget _buildInfoCard({
          required IconData icon,
          required String value,
        }) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8), // ← gap antar card
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // ← rounded per card
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildInfoRow(icon: icon, value: value),
          );
        }

  // ── Avatar ────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Container(
      width: 90,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9),
        
      ),
      child: CircleAvatar(
        child: Image.asset(
          'assets/images/person_1.png',
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            size: 48,
            color: Color(0xFF2ECC71),
          ),
        ),
      ),
    );
  }

  // ── Info Row ──────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isFirst ? 16 : 12,
        bottom: isLast ? 16 : 12,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

}