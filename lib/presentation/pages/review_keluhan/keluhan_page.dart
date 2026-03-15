// ============================================================
// FRONTEND LAYER — keluhan_list_page.dart
// Sesuai Figma (layar kanan): header hijau "Keluhan",
// tombol "Lapor keluhan", daftar kartu keluhan dengan
// foto, judul, tanggal, dan status badge.
// ============================================================

import 'package:flutter/material.dart';
import 'keluhan_controller.dart';

class KeluhanListPage extends StatefulWidget {
  const KeluhanListPage({super.key});

  @override
  State<KeluhanListPage> createState() => _KeluhanListPageState();
}

class _KeluhanListPageState extends State<KeluhanListPage> {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  // ── Header hijau ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF2ECC71),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Keluhan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Tombol Lapor Keluhan
          GestureDetector(
            onTap: () => _controller.goToLaporKeluhan(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Lapor keluhan',
                style: TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Konten ────────────────────────────────────────────────
  Widget _buildContent() {
    if (_controller.isLoadingList) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
    }

    if (_controller.errorList != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(_controller.errorList!,
                  style: const TextStyle(color: Color(0xFF9E9E9E))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadKeluhanList,
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

    if (_controller.keluhanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.report_problem_outlined,
                size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 14),
            const Text('Belum ada keluhan',
                style:
                    TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _controller.goToLaporKeluhan(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Lapor Sekarang',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2ECC71),
      onRefresh: _controller.loadKeluhanList,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.keluhanList.length,
        itemBuilder: (context, index) {
          final keluhan = _controller.keluhanList[index];
          return _KeluhanCard(
            keluhan: keluhan,
            statusLabel: _controller.statusLabel(keluhan.statusKeluhan),
            statusColor: _controller.statusColor(keluhan.statusKeluhan),
          );
        },
      ),
    );
  }
}

// ── Keluhan Card ──────────────────────────────────────────────
class _KeluhanCard extends StatelessWidget {
  final keluhan;
  final String statusLabel;
  final Color statusColor;

  const _KeluhanCard({
    required this.keluhan,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto bukti / placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: keluhan.fotoBukti != null && keluhan.fotoBukti!.isNotEmpty
                ? Image.network(
                    keluhan.fotoBukti!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Info keluhan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deskripsi (diambil 1 baris)
                Text(
                  keluhan.deskripsiMasalah,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Tanggal
                Text(
                  keluhan.tglLapor,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 6),
                // Status badge
                Row(
                  children: [
                    const Text('Status : ',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF555555))),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.image_outlined,
          color: Color(0xFF2ECC71), size: 24),
    );
  }
}