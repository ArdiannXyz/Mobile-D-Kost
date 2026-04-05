// ============================================================
// FRONTEND LAYER — setting_page.dart
// Sesuai Figma: header hijau dengan avatar bulat putih,
// menu list dengan icon dari assets D'Kost, logout merah.
//
// Yang DIHAPUS dari versi lama:
// - SvgPicture pattern_s.svg (diganti header hijau solid)
// - Menu "Pesanan Saya" dengan status pengiriman
// - SharedPreferences inline di widget
// ============================================================

import 'package:flutter/material.dart';
import 'setting_controller.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final SettingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Header hijau + avatar ──────────────────────────
          _buildHeader(),

          // ── Menu list ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildMenuGroup([
                    _MenuItem(
                      assetIcon: 'assets/images/kamarku_green.png',
                      label: 'Kamarku',
                      onTap: () => _controller.goToKamarku(context),
                    ),
                    _MenuItem(
                      assetIcon: 'assets/images/detail_informasi_akun.png',
                      label: 'Detail Informasi Akun',
                      onTap: () => _controller.goToDetailAkun(context),
                    ),
                    _MenuItem(
                      assetIcon: 'assets/images/keluhan_black.png',
                      label: 'Panduan',
                      onTap: () => _controller.goToPanduan(context),
                    ),
                     _MenuItem(
                      assetIcon: 'assets/images/sinora_icon.png', 
                      label: 'Sinora AI',
                      onTap: () => _controller.goToSinora(context),
                    ),                    
                     _MenuItem(
                      assetIcon:
                          'assets/images/change-password-icon.png',
                      label: 'Lupa Password',
                      onTap: () =>
                          _controller.goToLupaPassword(context),
                    ),
                  ]),
                  
                  _buildMenuGroup([
                    _MenuItem(
                      assetIcon: 'assets/images/logout.png',
                      label: 'Logout',
                      isDestructive: true,
                      onTap: () => _controller.confirmLogout(context),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),  // ← sesuaikan angkanya
          bottomRight: Radius.circular(18),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
      ),
      child: Column(
        children: [
         SizedBox(height: 10,),
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/person_1.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nama user
          if (!_controller.isLoading)
            Text(
              _controller.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          // Email user
          if (!_controller.isLoading && _controller.userEmail.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _controller.userEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Menu Group ────────────────────────────────────────────
Widget _buildMenuGroup(List<_MenuItem> items) {
  return Column(
    children: items.map((item) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // ← gap antar card
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // ← rounded per item
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: _buildMenuTile(item),
      ),
    )).toList(),
  );
}

  Widget _buildMenuTile(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon dari asset
            SizedBox(
              width: 28,
              height: 32,
              child: Image.asset(
                item.assetIcon,
                width: 24,
                height: 24,
                color: item.isDestructive
                    ? Colors.red.shade400
                    : const Color(0xFF555555),
                errorBuilder: (_, __, ___) => Icon(
                  item.isDestructive ? Icons.logout : Icons.settings,
                  size: 22,
                  color: item.isDestructive
                      ? Colors.red.shade400
                      : const Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: item.isDestructive
                      ? Colors.red.shade400
                      : const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Chevron (hanya untuk menu non-destructive)
            if (!item.isDestructive)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFB0B0C3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Data class untuk menu item ────────────────────────────────
class _MenuItem {
  final String assetIcon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.assetIcon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}