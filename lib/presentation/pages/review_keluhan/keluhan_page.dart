// ============================================================
// FRONTEND LAYER — keluhan_list_page.dart
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'keluhan_controller.dart';
import 'package:dkost/main.dart';

class KeluhanListPage extends StatefulWidget {
  const KeluhanListPage({super.key});

  @override
  State<KeluhanListPage> createState() => _KeluhanListPageState();
}

class _KeluhanListPageState extends State<KeluhanListPage> with RouteAware {
  late final KeluhanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KeluhanController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadKeluhanList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); 
    super.dispose();
  }

  
  @override
  void didPopNext() {
    _controller.loadKeluhanList();// refresh saat kembali ke halaman ini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1BBA8A),
            borderRadius: BorderRadius.only(
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x222ECC71),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: const Center(
            child: Text(
              'Keluhan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // ── Bagian putih: "Daftar Keluhan" + tombol ──────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Daftar Keluhan',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _controller.goToLaporKeluhan(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1BBA8A),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Text(
                    'Lapor keluhan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildContent() {
    if (_controller.isLoadingList) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1BBA8A)));
    }
    if (_controller.errorList != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(_controller.errorList!, style: const TextStyle(color: Color(0xFF9E9E9E))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadKeluhanList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBA8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller.keluhanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 14),
            const Text('Belum ada keluhan', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _controller.goToLaporKeluhan(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF1BBA8A), borderRadius: BorderRadius.circular(20)),
                child: const Text('Lapor Sekarang', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF1BBA8A),
      onRefresh: _controller.loadKeluhanList,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: _controller.keluhanList.length,
        itemBuilder: (context, index) {
          final keluhan = _controller.keluhanList[index];
          return _KeluhanCard(
            keluhan: keluhan,
            statusLabel: _controller.statusLabel(keluhan.statusKeluhan),
            statusColor: _controller.statusColor(keluhan.statusKeluhan),
            onTap: () => _controller.showEditDialog(context, keluhan), // ← tambah
          );
        },
      ),
    );
  }
}

class _KeluhanCard extends StatelessWidget {
  final dynamic keluhan;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onTap; // ← tambah

  const _KeluhanCard({
    required this.keluhan,
    required this.statusLabel,
    required this.statusColor,
    this.onTap, // ← tambah
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildFoto(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keluhan.deskripsiMasalah,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal Lapor : ${_formatTanggal(keluhan.tglLapor)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Status : ', style: TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
                      Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoto() {
    final foto = keluhan.fotoBukti;
    if (foto == null || foto.isEmpty) return _placeholder();

    if (foto.startsWith('data:image')) {
      try {
        final base64Str = foto.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder());
      } catch (_) {
        return _placeholder();
      }
    }

    return Image.network(foto, width: 80, height: 80, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder());
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.image_outlined, color: Color(0xFF1BBA8A), size: 28),
    );
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw.replaceAll(' ', 'T'));
      return '${dt.day.toString().padLeft(2,'0')} - ${dt.month.toString().padLeft(2,'0')} - ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}