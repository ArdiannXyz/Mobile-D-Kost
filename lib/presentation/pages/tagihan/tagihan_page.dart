import 'package:flutter/material.dart';
import 'tagihan_controller.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  late final TagihanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TagihanController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadTagihan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF2ECC71),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
      ),
      child: const Center(
        child: Text(
          'Tagihan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────────
  Widget _buildFilterChips() {
    const filters = ['Belum Bayar', 'Telat', 'Lunas'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ...filters.map((f) {
            final isSelected = _controller.selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _controller.filterTagihan(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2ECC71)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF555555),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => _controller.showInfo(context),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────
  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(_controller.errorMessage!,
                  style: const TextStyle(color: Color(0xFF9E9E9E))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadTagihan,
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

    if (_controller.filteredTagihan.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 14),
            Text(
              'Tidak ada tagihan ${_controller.selectedFilter.toLowerCase()}',
              style: const TextStyle(
                  color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2ECC71),
      onRefresh: _controller.loadTagihan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.filteredTagihan.length,
        itemBuilder: (context, index) {
          final tagihan = _controller.filteredTagihan[index];
          return _TagihanCard(
            tagihan: tagihan,
            controller: _controller,
            onTap: () => _controller.goToDetail(context, tagihan),
          );
        },
      ),
    );
  }
}

// ── Tagihan Card ───────────────────────────────────────────────
class _TagihanCard extends StatelessWidget {
  final TagihanUiModel tagihan;
  final TagihanController controller;
  final VoidCallback onTap;

  const _TagihanCard({
    required this.tagihan,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Foto kamar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: tagihan.fotoKamar != null
                    ? Image.network(
                        tagihan.fotoKamar!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagihan.namaKamar ?? 'Kamar',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sewa : ${controller.formatTanggal(tagihan.periodeAwal)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    Text(
                      'Berakhir : ${controller.formatTanggal(tagihan.periodeAkhir)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.formatHarga(tagihan.totalTagihan),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        // Tombol bayar — hanya muncul kalau belum lunas
                        if (tagihan.statusTagihan != 'lunas')
                          SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.bayar(context, tagihan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2ECC71),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Bayar',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.bed_outlined,
          color: Color(0xFF2ECC71), size: 28),
    );
  }
}