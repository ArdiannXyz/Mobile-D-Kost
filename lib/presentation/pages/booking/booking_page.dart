// ============================================================
// FRONTEND LAYER — booking_pages.dart
// Berisi 2 halaman sesuai Figma:
// 1. DetailKamarkuPage — detail booking aktif
// 2. CheckoutPage     — konfirmasi sebelum buat pesanan
// ============================================================

import 'package:flutter/material.dart';
import 'booking_controller.dart';
import '../../../data/models/kamar_models.dart';
import '../../../data/models/furnitur_models.dart';

// ══════════════════════════════════════════════════════════════
// 1. DETAIL KAMARKU PAGE
// ══════════════════════════════════════════════════════════════
class DetailKamarkuPage extends StatefulWidget {
  final int bookingId;
  const DetailKamarkuPage({super.key, required this.bookingId});

  @override
  State<DetailKamarkuPage> createState() => _DetailKamarkuPageState();
}

class _DetailKamarkuPageState extends State<DetailKamarkuPage> {
  late final DetailKamarkuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DetailKamarkuController(
      bookingId: widget.bookingId,
      onStateChanged: () { if (mounted) setState(() {}); },
    );
    _controller.loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar('Detail Kamarku'),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : _controller.errorMessage != null
              ? _errorView(_controller.errorMessage!, _controller.loadDetail)
              : RefreshIndicator(
                  color: const Color(0xFF2ECC71),
                  onRefresh: _controller.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoPemesanan(),
                        const SizedBox(height: 12),
                        _buildKamarCard(),
                        if (_controller.booking!.furniturList.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildFurniturSection(),
                        ],
                        const SizedBox(height: 12),
                        _buildRincianPembayaran(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _controller.booking != null &&
              _controller.booking!.statusBooking == 'menunggu_pembayaran'
          ? _buildBottomBar()
          : null,
    );
  }

  // ── Info Pemesanan Card ────────────────────────────────────
  Widget _buildInfoPemesanan() {
    final b = _controller.booking!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Info Pemesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          _infoRow('Tanggal Booking', _controller.formatTanggal(b.tglBooking)),
          _infoRow('Mulai Sewa', _controller.formatTanggal(b.tglMulaiSewa)),
          _infoRow('Akhir Sewa', _controller.formatTanggal(b.tglAkhirSewa)),
          _infoRow('Metode Pembayaran',
              b.tagihan?.statusTagihan == 'lunas' ? 'Bank Mandiri' : '-'),
        ],
      ),
    );
  }

  // ── Kamar Card ─────────────────────────────────────────────
  Widget _buildKamarCard() {
    final b = _controller.booking!;
    return _card(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: b.fotoKamar != null
                ? Image.network(b.fotoKamar!, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _kamarPlaceholder())
                : _kamarPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kos ${_cap(b.tipeKamar ?? '')} ${b.nomorKamar ?? ''}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 6),
                Text(
                  _controller.formatHarga(b.totalBiayaBulanan),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Furnitur Section ───────────────────────────────────────
  Widget _buildFurniturSection() {
    return Column(
      children: _controller.booking!.furniturList
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Furnitur Tambahan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chair_outlined, color: Color(0xFF2ECC71), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.namaFurnitur,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('${f.jumlah}x',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                          Text(_controller.formatHarga(f.subtotal),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── Rincian Pembayaran ─────────────────────────────────────
  Widget _buildRincianPembayaran() {
    final b = _controller.booking!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _rincianRow('Subtotal biaya produk',
              _controller.formatHarga(b.totalBiayaBulanan)),
          _rincianRow('Biaya layanan', _controller.formatHarga(2000)),
          const Divider(height: 20),
          _rincianRow('Total Pembayaran',
              _controller.formatHarga(_controller.totalBiaya + 2000),
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => _controller.goToPayment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Bayar Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// 2. CHECKOUT PAGE
// ══════════════════════════════════════════════════════════════
class CheckoutPage extends StatefulWidget {
  final KamarModel kamar;
  final int durasiSewa;
  final Map<int, int> selectedFurnitur;
  final List<FurniturModel> furniturList;
  final String tglMulaiSewa;

  const CheckoutPage({
    super.key,
    required this.kamar,
    required this.durasiSewa,
    required this.selectedFurnitur,
    required this.furniturList,
    required this.tglMulaiSewa,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CheckoutController(
      kamar: widget.kamar,
      durasiSewa: widget.durasiSewa,
      selectedFurnitur: widget.selectedFurnitur,
      furniturList: widget.furniturList,
      tglMulaiSewa: widget.tglMulaiSewa,
      onStateChanged: () { if (mounted) setState(() {}); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar('Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoPemesanan(),
            const SizedBox(height: 12),
            _buildKamarCard(),
            if (_controller.furniturItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildFurniturSection(),
            ],
            const SizedBox(height: 12),
            _buildRincianPembayaran(),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildInfoPemesanan() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Info Pemesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          _infoRow('Tanggal Booking', _controller.formatTanggal(DateTime.now().toIso8601String())),
          _infoRow('Mulai Sewa', _controller.formatTanggal(widget.tglMulaiSewa)),
          _infoRow('Akhir Sewa', _controller.tglAkhirSewa),
          _infoRow('Metode Pembayaran', 'Bank Mandiri'),
        ],
      ),
    );
  }

  Widget _buildKamarCard() {
    final kamar = widget.kamar;
    return _card(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kamar.fotoPrimary != null
                ? Image.network(kamar.fotoPrimary!, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _kamarPlaceholder())
                : _kamarPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kos ${_cap(kamar.tipeKamar)} ${kamar.nomorKamar}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 6),
                Text(
                  _controller.formatHarga(_controller.totalKamar),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFurniturSection() {
    return Column(
      children: _controller.furniturItems
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Furnitur Tambahan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chair_outlined,
                                color: Color(0xFF2ECC71), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.nama,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('${f.jumlah}x',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                          Text(_controller.formatHarga(f.subtotal),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRincianPembayaran() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _rincianRow('Subtotal biaya produk',
              _controller.formatHarga(_controller.totalKamar)),
          _rincianRow('Biaya layanan', _controller.formatHarga(2000)),
          const Divider(height: 20),
          _rincianRow('Total Pembayaran',
              _controller.formatHarga(_controller.totalPembayaran + 2000),
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12),
      child: Row(
        children: [
          // Total di kiri
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total :', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                Text(
                  _controller.formatHarga(_controller.totalPembayaran + 2000),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),
          // Tombol Buat Pesanan
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _controller.isSubmitting
                  ? null
                  : () => _controller.buatPesanan(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                disabledBackgroundColor: const Color(0xFF2ECC71).withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _controller.isSubmitting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Buat Pesanan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED HELPERS (dipakai kedua halaman)
// ══════════════════════════════════════════════════════════════

PreferredSizeWidget _appBar(String title) {
  return AppBar(
    backgroundColor: const Color(0xFF2ECC71),
    elevation: 0,
    leading: Builder(builder: (ctx) => IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
      onPressed: () => Navigator.pop(ctx),
    )),
    centerTitle: true,
    title: Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
  );
}

Widget _card({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: child,
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        ),
        const Text(': ', style: TextStyle(color: Color(0xFF555555))),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

Widget _rincianRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: isBold ? const Color(0xFF1A1A2E) : const Color(0xFF555555),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF1A1A2E),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    ),
  );
}

Widget _kamarPlaceholder() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.bed_outlined, color: Color(0xFF2ECC71), size: 32),
  );
}

Widget _errorView(String message, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Color(0xFFB0B0C3)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9E9E9E))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
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

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
