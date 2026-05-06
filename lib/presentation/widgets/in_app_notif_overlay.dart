// lib/features/notifikasi/widgets/in_app_notif_overlay.dart
//
// Tampilkan popup notifikasi saat app terbuka (foreground).
// Cara pakai: bungkus halaman utama dengan InAppNotifOverlay(child: ...)

import 'package:flutter/material.dart';
import '../../../data/models/notifikasi_model.dart';
import '../pages/notifikasi/notifikasi_manager.dart';

class InAppNotifOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotifOverlay({super.key, required this.child});

  @override
  State<InAppNotifOverlay> createState() => _InAppNotifOverlayState();
}

class _InAppNotifOverlayState extends State<InAppNotifOverlay>
    with TickerProviderStateMixin {
  final List<_NotifEntry> _queue = [];
  bool _isShowing = false;

  // ── Panggil ini dari OneSignal handler ────────────────────
  static _InAppNotifOverlayState? _instance;
  static void show(NotifikasiItem item) {
    _instance?._enqueue(item);
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  void _enqueue(NotifikasiItem item) {
    final entry = _NotifEntry(
      item: item,
      controller: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _queue.add(entry);
    if (!_isShowing) _showNext();
  }

  Future<void> _showNext() async {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }
    _isShowing = true;
    final entry = _queue.first;
    setState(() {});

    await entry.controller.forward();
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) await _dismiss(entry);
  }

  Future<void> _dismiss(_NotifEntry entry) async {
    await entry.controller.reverse();
    if (mounted) {
      setState(() => _queue.remove(entry));
    }
    entry.controller.dispose();
    _showNext();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_queue.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: _NotifBanner(
              entry: _queue.first,
              onDismiss: () => _dismiss(_queue.first),
            ),
          ),
      ],
    );
  }
}

// ── Entry data ─────────────────────────────────────────────
class _NotifEntry {
  final NotifikasiItem item;
  final AnimationController controller;
  _NotifEntry({required this.item, required this.controller});
}

// ── Banner UI ──────────────────────────────────────────────
class _NotifBanner extends StatelessWidget {
  final _NotifEntry entry;
  final VoidCallback onDismiss;

  const _NotifBanner({required this.entry, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final animation = CurvedAnimation(
      parent: entry.controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1.5),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onDismiss,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF1BBA8A).withOpacity(0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1BBA8A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(item.tipe),
                    color: const Color(0xFF1BBA8A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1BBA8A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.pesan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dismiss button
                GestureDetector(
                  onTap: onDismiss,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotifikasiTipe tipe) {
    switch (tipe) {
      case NotifikasiTipe.tagihan:
        return Icons.receipt_long_rounded;
      case NotifikasiTipe.keluhan:
        return Icons.person_outline_rounded;
      case NotifikasiTipe.umum:
        return Icons.notifications_outlined;
    }
  }
}