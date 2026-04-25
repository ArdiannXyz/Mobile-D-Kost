// ============================================================
// FILE: lib/presentation/pages/kamarku/booking_pages.dart
// ============================================================

import 'package:flutter/material.dart';
import 'detail_kamarku_controller.dart';
import '../../../data/models/kamar_models.dart';
import '../../../data/models/furnitur_models.dart';
import '../../../data/models/payment_model.dart';

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
      bookingId     : widget.bookingId,
      onStateChanged: () { if (mounted) setState(() {}); },
    );
    _controller.loadDetail().then((_) {
      _controller.startCountdown(() {
        if (mounted) _onExpired();
      });
    });
  }

  @override
  void dispose() {
    _controller.stopCountdown();
    super.dispose();
  }

  void _onExpired() {
    _controller.batalBooking(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1BBA8A)))
          : _controller.errorMessage != null
              ? _errorView(_controller.errorMessage!, _controller.loadDetail)
              : RefreshIndicator(
                  color    : const Color(0xFF1BBA8A),
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
                        // ── FITUR BARU: Tagihan bulan ini (hanya jika aktif) ──
                        if (_controller.booking!.statusBooking == 'aktif') ...[
                          const SizedBox(height: 12),
                          _buildTagihanBulanIni(),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── AppBar — tombol + furnitur jika aktif ─────────────────
  PreferredSizeWidget _buildAppBar() {
    final isAktif = _controller.booking?.statusBooking == 'aktif';
    return AppBar(
      backgroundColor: const Color(0xFF1BBA8A),
      elevation      : 0,
      leading: IconButton(
        icon     : const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text('Detail Kamarku',
          style: TextStyle(
              color     : Colors.white,
              fontSize  : 16,
              fontWeight: FontWeight.w600)),
      actions: [
        if (isAktif && !_controller.isLoading)
          IconButton(
            icon   : const Icon(Icons.add_shopping_cart_outlined,
                color: Colors.white),
            tooltip: 'Tambah Furnitur',
            onPressed: _controller.isSubmitting
                ? null
                : () => _controller.showTambahFurniturDialog(context),
          ),
      ],
    );
  }

  // ── Info Pemesanan + Countdown Timer ──────────────────────
  Widget _buildInfoPemesanan() {
    final b          = _controller.booking!;
    final isMenunggu = b.statusBooking == 'menunggu_pembayaran';
    final isLunas = b.tagihan?.statusTagihan == 'lunas';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Info Pemesanan',
              style: TextStyle(
                  fontSize  : 14,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          _infoRow('Tanggal Booking',
              _controller.formatTanggal(b.tglBooking)),
          _infoRow('Mulai Sewa',
              _controller.formatTanggal(b.tglMulaiSewa)),
          _infoRow('Akhir Sewa',
              _controller.formatTanggal(b.tglAkhirSewa)),
          _infoRow(
            'Status',
            _controller.statusLabel(b.statusBooking),
            valueColor: _controller.statusColor(b.statusBooking),
          ),

          // ── Countdown — hanya saat menunggu_pembayaran ──
          // ── Countdown — hanya saat menunggu_pembayaran DAN belum lunas ──
            
            if (isMenunggu && !isLunas) ...[
            const SizedBox(height: 12),
            Container(
              width  : double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: _controller.isExpired
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _controller.isExpired
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFFF39C12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size : 18,
                    color: _controller.isExpired
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFFF39C12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.isExpired
                          ? 'Waktu pembayaran habis!'
                          : 'Selesaikan pembayaran dalam',
                      style: TextStyle(
                        fontSize: 12,
                        color: _controller.isExpired
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFFF39C12),
                      ),
                    ),
                  ),
                  Text(
                    _controller.countdownText,
                    style: TextStyle(
                      fontSize  : 16,
                      fontWeight: FontWeight.bold,
                      color: _controller.isExpired
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFFF39C12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKamarCard() {
    final b = _controller.booking!;
    return _card(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: b.fotoKamar != null
                ? Image.network(
                    b.fotoKamar!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _kamarPlaceholder(),
                  )
                : _kamarPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kos ${_cap(b.tipeKamar ?? '')} ${b.nomorKamar ?? ''}',
                  style: const TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 6),
                Text(
                  _controller.formatHarga(b.totalBiayaBulanan),
                  style: const TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Furnitur — dengan tombol Tambah inline jika aktif ─────
  Widget _buildFurniturSection() {
    final b       = _controller.booking!;
    final isAktif = b.statusBooking == 'aktif';
  
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Furnitur Tambahan',
                  style: TextStyle(
                      fontSize  : 13,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E))),
              const Spacer(),
              // ── Tombol tambah furnitur inline ──────────────
              if (isAktif)
                GestureDetector(
                  onTap: _controller.isSubmitting
                      ? null
                      : () => _controller.showTambahFurniturDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color       : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Color(0xFF1BBA8A)),
                        SizedBox(width: 4),
                        Text('Tambah',
                            style: TextStyle(
                                fontSize  : 12,
                                color     : Color(0xFF1BBA8A),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...b.furniturList.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width : 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color       : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chair_outlined,
                          color: Color(0xFF1BBA8A), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.namaFurnitur,
                              style: const TextStyle(
                                  fontSize  : 13,
                                  fontWeight: FontWeight.w500)),
                          Text('${f.jumlah}x',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color   : Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Text(
                      _controller.formatHarga(f.subtotal),
                      style: const TextStyle(
                          fontSize  : 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRincianPembayaran() {
    final b = _controller.booking!;
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Pembayaran',
              style: TextStyle(
                  fontSize  : 14,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          Text(
            _controller.formatHarga(b.totalBiayaBulanan),
            style: const TextStyle(
                fontSize  : 14,
                fontWeight: FontWeight.bold,
                color     : Color(0xFF1BBA8A)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FITUR BARU: Tagihan Bulan Ini
  // Tampil otomatis tiap bulan (di-generate backend via scheduler)
  // ══════════════════════════════════════════════════════════
  Widget _buildTagihanBulanIni() {
    final tagihan = _controller.booking?.tagihan;
    if (tagihan == null) return const SizedBox.shrink();

    final isLunas = tagihan.statusTagihan == 'lunas';
    final color   = isLunas
        ? const Color(0xFF1BBA8A)
        : const Color(0xFFF39C12);
    final b       = _controller.booking!;
    final namaKamar =
        'Kos ${_cap(b.tipeKamar ?? '')} ${b.nomorKamar ?? ''}';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              const Text('Tagihan Bulan Ini',
                  style: TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color       : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border      : Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  isLunas ? 'Lunas' : 'Belum Bayar',
                  style: TextStyle(
                      fontSize  : 11,
                      color     : color,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Total tagihan ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Tagihan',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF555555))),
              Text(
                _controller.formatHarga(tagihan.totalTagihan),
                style: const TextStyle(
                    fontSize  : 13,
                    fontWeight: FontWeight.w600,
                    color     : Color(0xFF1A1A2E)),
              ),
            ],
          ),

          // ── Jatuh tempo ──────────────────────────────────
          if (tagihan.tglJatuhTempo != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jatuh Tempo',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF555555))),
                Text(
                  _controller.formatTanggal(tagihan.tglJatuhTempo!),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ],

          // ── Tombol bayar (hanya jika belum lunas) ────────
          if (!isLunas) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                    onPressed: () => _controller.goToPayment(
                      context,
                      idTagihan : tagihan.idTagihan,
                      totalBayar: tagihan.totalTagihan,
                      namaKamar : namaKamar,
                      onNeedMethod: () => showModalBottomSheet<PaymentMethodType>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const _PilihMetodeSheet(),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBA8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Bayar Sekarang',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Bottom Bar — beda tampilan per status booking
  // ══════════════════════════════════════════════════════════
  Widget? _buildBottomBar() {
    final b = _controller.booking;
    if (b == null || _controller.isLoading) return null;

    // ── Status menunggu_pembayaran: Batal + Bayar (asli) ──
      if (b.statusBooking == 'menunggu_pembayaran') {
    final idTagihan  = b.tagihan?.idTagihan;
    final totalBayar = _controller.totalBiaya;
    final namaKamar  = 'Kos ${_cap(b.tipeKamar ?? '')} ${b.nomorKamar ?? ''}';

    // ── Jika tagihan sudah lunas, sembunyikan bottom bar ──
    final isLunas = b.tagihan?.statusTagihan == 'lunas';
    if (isLunas) return null;
      return Container(
        color  : Colors.white,
        padding: EdgeInsets.only(
          left  : 16,
          right : 16,
          top   : 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // ── Tombol Batal ─────────────────────────────
            ElevatedButton(
              onPressed: () => _controller.batalBooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              child: const Text('Batal',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            // ── Tombol Bayar Sekarang ─────────────────────
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                 onPressed: (idTagihan == null || _controller.isExpired)
                    ? null
                    : () => _controller.goToPayment(
                          context,
                          idTagihan : idTagihan,
                          totalBayar: totalBayar,
                          namaKamar : namaKamar,
                          onNeedMethod: () => showModalBottomSheet<PaymentMethodType>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => const _PilihMetodeSheet(),
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor        : const Color(0xFF1BBA8A),
                    disabledBackgroundColor: const Color(0xFF9E9E9E),
                    foregroundColor        : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Bayar Sekarang',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Status aktif: + Furnitur + Akhiri Sewa ────────────
    if (b.statusBooking == 'aktif') {
      return Container(
        color  : Colors.white,
        padding: EdgeInsets.only(
          left  : 16,
          right : 16,
          top   : 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // ── Tambah Furnitur ──────────────────────────
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _controller.isSubmitting
                    ? null
                    : () => _controller.showTambahFurniturDialog(context),
                icon : const Icon(Icons.add_shopping_cart_outlined,
                    size: 18),
                label: const Text('+ Furnitur'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1BBA8A),
                  side : const BorderSide(color: Color(0xFF1BBA8A)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  textStyle: const TextStyle(
                      fontSize  : 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Akhiri Sewa ──────────────────────────────
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _controller.isSubmitting
                      ? null
                      : () => _controller.akhiriSewa(context),
                  icon: _controller.isSubmitting
                      ? const SizedBox(
                          width : 16,
                          height: 16,
                          child : CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.exit_to_app_rounded, size: 18),
                  label: const Text('Akhiri Sewa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize  : 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }
}

// ══════════════════════════════════════════════════════════════
// 2. CHECKOUT PAGE — tidak diubah sama sekali
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
      kamar           : widget.kamar,
      durasiSewa      : widget.durasiSewa,
      selectedFurnitur: widget.selectedFurnitur,
      furniturList    : widget.furniturList,
      tglMulaiSewa    : widget.tglMulaiSewa,
      onStateChanged  : () { if (mounted) setState(() {}); },
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
              style: TextStyle(
                  fontSize  : 14,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          
          _infoRow('Tanggal Booking',
              _controller.formatTanggal(DateTime.now().toIso8601String())),
          _infoRow('Mulai Sewa',
              _controller.formatTanggal(widget.tglMulaiSewa)),
          _infoRow('Akhir Sewa', _controller.tglAkhirSewa),
          _infoRow('Durasi', '${widget.durasiSewa} Bulan'),
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
                ? Image.network(
                    kamar.fotoPrimary!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _kamarPlaceholder(),
                  )
                : _kamarPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kos ${_cap(kamar.tipeKamar)} ${kamar.nomorKamar}',
                  style: const TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.durasiSewa} Bulan',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.formatHarga(_controller.totalKamar),
                  style: const TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1BBA8A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFurniturSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Furnitur Tambahan',
              style: TextStyle(
                  fontSize  : 13,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          ..._controller.furniturItems.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width : 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color       : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chair_outlined,
                          color: Color(0xFF1BBA8A), size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.nama,
                              style: const TextStyle(
                                  fontSize  : 13,
                                  fontWeight: FontWeight.w500)),
                          Text('${f.jumlah}x',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color   : Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Text(
                      _controller.formatHarga(f.subtotal),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRincianPembayaran() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran',
              style: TextStyle(
                  fontSize  : 14,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _rincianRow(
            'Biaya kamar (${widget.durasiSewa} bln)',
            _controller.formatHarga(_controller.totalKamar),
          ),
          if (_controller.totalFurnitur > 0)
            _rincianRow(
              'Biaya furnitur',
              _controller.formatHarga(_controller.totalFurnitur),
            ),
          const Divider(height: 20),
          _rincianRow(
            'Total Pembayaran',
            _controller.formatHarga(_controller.totalPembayaran),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color  : Colors.white,
      padding: EdgeInsets.only(
        left  : 16,
        right : 16,
        top   : 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize      : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total :',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E))),
                Text(
                  _controller.formatHarga(_controller.totalPembayaran),
                  style: const TextStyle(
                      fontSize  : 15,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _controller.isSubmitting
                  ? null
                  : () => _controller.buatPesanan(context),
              style: ElevatedButton.styleFrom(
                backgroundColor        : const Color(0xFF1BBA8A),
                disabledBackgroundColor:
                    const Color(0xFF1BBA8A).withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _controller.isSubmitting
                  ? const SizedBox(
                      width : 20,
                      height: 20,
                      child : CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Buat Pesanan',
                      style: TextStyle(
                          fontSize  : 15,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED HELPERS — tidak diubah
// ══════════════════════════════════════════════════════════════

PreferredSizeWidget _appBar(String title) {
  return AppBar(
    backgroundColor: const Color(0xFF1BBA8A),
    elevation      : 0,
    leading: Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(ctx),
      ),
    ),
    centerTitle: true,
    title: Text(title,
        style: const TextStyle(
            color     : Colors.white,
            fontSize  : 16,
            fontWeight: FontWeight.w600)),
  );
}

Widget _card({required Widget child}) {
  return Container(
    width  : double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color       : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow   : const [
        BoxShadow(
            color     : Color(0x0A000000),
            blurRadius: 6,
            offset    : Offset(0, 2))
      ],
    ),
    child: child,
  );
}

Widget _infoRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555555))),
        ),
        const Text(': ',
            style: TextStyle(color: Color(0xFF555555))),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize  : 13,
                  color     : valueColor ?? const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500)),
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
                fontSize  : 13,
                color     : isBold
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF555555),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize  : 13,
                color     : const Color(0xFF1A1A2E),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    ),
  );
}

Widget _kamarPlaceholder() {
  return Container(
    width : 80,
    height: 80,
    decoration: BoxDecoration(
      color       : const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.bed_outlined,
        color: Color(0xFF1BBA8A), size: 32),
  );
}

Widget _errorView(String message, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 56, color: Color(0xFFB0B0C3)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9E9E9E))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
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

String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

    class _PilihMetodeSheet extends StatefulWidget {
  const _PilihMetodeSheet();

  @override
  State<_PilihMetodeSheet> createState() => _PilihMetodeSheetState();
}

class _PilihMetodeSheetState extends State<_PilihMetodeSheet> {
  PaymentMethodType? _selected;

  String _logoPath(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bcaVa:     return 'assets/banks/bca.png';
      case PaymentMethodType.bniVa:     return 'assets/banks/bni.png';
      case PaymentMethodType.briVa:     return 'assets/banks/bri.png';
      case PaymentMethodType.mandiriVa: return 'assets/banks/mandiri.png';
      case PaymentMethodType.qris:      return 'assets/payment/qris.png';
      case PaymentMethodType.gopay:     return 'assets/payment/gopay.png';
      case PaymentMethodType.shopeepay: return 'assets/payment/shopeepay.png';
    }
  }

  Widget _buildGroup(String label, List<PaymentMethodType> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
                letterSpacing: 0.4)),
        const SizedBox(height: 6),
        ...methods.map((method) {
          final isSelected = _selected == method;
          return GestureDetector(
            onTap: () => setState(() => _selected = method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1BBA8A)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 28,
                    child: Image.asset(
                      _logoPath(method),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_balance, size: 20, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      method.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1BBA8A)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF1BBA8A)
                          : Colors.white,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

@override
Widget build(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize    : 0.4,
    maxChildSize    : 0.92,
    expand          : false,
    builder: (_, scrollController) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle bar ─────────────────────────────────
          Container(
            width : 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih Metode Pembayaran',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
            ),
          ),
          const SizedBox(height: 12),

          // ── Scrollable list ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGroup('Transfer Bank', [
                    PaymentMethodType.bcaVa,
                    PaymentMethodType.bniVa,
                    PaymentMethodType.briVa,
                    PaymentMethodType.mandiriVa,
                  ]),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _buildGroup('QRIS', [PaymentMethodType.qris]),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _buildGroup('Dompet Digital', [
                    PaymentMethodType.gopay,
                    PaymentMethodType.shopeepay,
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Tombol fixed di bawah ──────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x15000000),
                    blurRadius: 8,
                    offset: Offset(0, -3)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  disabledBackgroundColor:
                      const Color(0xFF1BBA8A).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Lanjut Bayar',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}