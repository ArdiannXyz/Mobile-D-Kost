// lib/features/notifikasi/widgets/notifikasi_badge.dart
//
// Badge merah dengan angka unread di atas ikon notifikasi.
// Otomatis update karena listen ke NotifikasiManager (ChangeNotifier).
//
// Cara pakai di AppBar:
//   actions: [
//     NotifikasiBadge(
//       onTap: () => Navigator.push(context, ...),
//     ),
//   ]

import 'package:flutter/material.dart';
import '../pages/notifikasi/notifikasi_manager.dart';

class NotifikasiBadge extends StatefulWidget {
  final VoidCallback? onTap;
  final Color iconColor;
  final double iconSize;

  const NotifikasiBadge({
    super.key,
    this.onTap,
    this.iconColor = Colors.white,
    this.iconSize = 24,
  });

  @override
  State<NotifikasiBadge> createState() => _NotifikasiBadgeState();
}

class _NotifikasiBadgeState extends State<NotifikasiBadge> {
  final _manager = NotifikasiManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onUpdate);
    // Muat jumlah badge saat pertama kali
    if (_manager.semua.isEmpty && !_manager.isLoading) {
      _manager.muat();
    }
  }

  @override
  void dispose() {
    _manager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final count = _manager.jumlahBelumDibaca;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: _BadgePill(count: count),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Badge pill (animasi saat berubah) ─────────────────────
class _BadgePill extends StatelessWidget {
  final int count;
  const _BadgePill({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Container(
        key: ValueKey(label),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4444),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}