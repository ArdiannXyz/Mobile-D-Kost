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
                  const SizedBox(height: 16),
                  _buildMenuGroup([
                    _MenuItem(
                      assetIcon: 'assets/images/detail informasi akun.png',
                      label: 'Detail Informasi Akun',
                      onTap: () => _controller.goToDetailAkun(context),
                    ),
                    _MenuItem(
                      assetIcon: 'assets/images/person 1.png',
                      label: 'Panduan',
                      onTap: () => _controller.goToPanduan(context),
                    ),
                    _MenuItem(
                      assetIcon:
                          'assets/images/change-password-icon (1).png',
                      label: 'Lupa Password',
                      onTap: () =>
                          _controller.goToLupaPassword(context),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _MenuItem(
                      assetIcon: 'assets/images/logout (2).png',
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
      color: const Color(0xFF2ECC71),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
      ),
      child: Column(
        children: [
          // Label "Setting" di kiri atas
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                'Setting',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

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
                'assets/images/person 1.png',
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
    return Container(
      color: Colors.white,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuTile(item),
              if (index < items.length - 1)
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: Color(0xFFF0F0F0),
                ),
            ],
          );
        }).toList(),
      ),
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
              height: 28,
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