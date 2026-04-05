// ============================================================
// FRONTEND LAYER — kamar_detail_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'detail_kamar_controller.dart';
import '../../../data/models/furnitur_models.dart';
import '../../../data/models/review_models.dart';

class KamarDetailPage extends StatefulWidget {
  final int kamarId;
  const KamarDetailPage({super.key, required this.kamarId});

  @override
  State<KamarDetailPage> createState() => _KamarDetailPageState();
}

class _KamarDetailPageState extends State<KamarDetailPage> {
  late final KamarDetailController _controller;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = KamarDetailController(
      kamarId: widget.kamarId,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : _controller.errorMessage != null
              ? _buildError()
              : _buildContent(),
      bottomNavigationBar: _controller.isLoading || _controller.kamar == null
          ? null
          : _buildBottomBar(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A2E), size: 18),
        onPressed: () => _controller.goBack(context),
      ),
      title: const Text(
        'Detail Kamar',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Konten Utama ──────────────────────────────────────────
  Widget _buildContent() {
    final kamar = _controller.kamar!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGallery(),
          _buildInfoSection(),
          const SizedBox(height: 8),
          _buildSection(
            title: 'Deskripsi Produk',
            child: Text(
              kamar.deskripsi.isEmpty ? 'Tidak ada deskripsi.' : kamar.deskripsi,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555555), height: 1.6),
            ),
          ),
          const SizedBox(height: 8),
          _buildRatingSection(),
          const SizedBox(height: 8),
          _buildReviewSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Gallery ───────────────────────────────────────────────
  Widget _buildGallery() {
    final kamar = _controller.kamar!;
    final hasPhoto = kamar.fotoPrimary != null && kamar.fotoPrimary!.isNotEmpty;

    return Stack(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: hasPhoto
              ? Image.network(
                  kamar.fotoPrimary!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderPhoto(),
                )
              : _placeholderPhoto(),
        ),
        if (hasPhoto)
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1/1',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholderPhoto() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(Icons.bed_outlined, color: Color(0xFF2ECC71), size: 64),
      ),
    );
  }

  // ── Info Section ──────────────────────────────────────────
  Widget _buildInfoSection() {
    final kamar = _controller.kamar!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Kos ${_cap(kamar.tipeKamar)} ${kamar.nomorKamar}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _controller.formatHarga(kamar.hargaPerBulan),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Text(
                    '/Bulan',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lama sewa',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _controller.durasiSewa,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: Color(0xFF555555)),
                          items: List.generate(12, (i) => i + 1)
                              .map((bulan) => DropdownMenuItem(
                                    value: bulan,
                                    child: Text(
                                      '$bulan Bulan',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF1A1A2E)),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _controller.setDurasi(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mulai sewa',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickTanggalMulai(context),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _controller.tglMulaiSewa != null
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE0E0E0),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/kalender_1.png',
                              width: 16,
                              height: 16,
                              color: _controller.tglMulaiSewa != null
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFF9E9E9E),
                              colorBlendMode: BlendMode.srcIn,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: _controller.tglMulaiSewa != null
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _controller
                                    .formatTanggal(_controller.tglMulaiSewa),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _controller.tglMulaiSewa != null
                                      ? const Color(0xFF1A1A2E)
                                      : const Color(0xFFB0B0C3),
                                  fontWeight: _controller.tglMulaiSewa != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_controller.tglAkhirSewa != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FBF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB7EAC8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Color(0xFF2ECC71)),
                  const SizedBox(width: 6),
                  Text(
                    'Akhir sewa: ${_controller.formatTanggal(_controller.tglAkhirSewa)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.w500,
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

  Future<void> _pickTanggalMulai(BuildContext context) async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 3));

    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.tglMulaiSewa ?? now,
      firstDate: now,
      lastDate: maxDate,
      helpText: 'Pilih Tanggal Mulai Sewa',
      confirmText: 'Pilih',
      cancelText: 'Batal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2ECC71),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2ECC71),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _controller.setTglMulai(picked);
    }
  }

  // ── Rating Section ────────────────────────────────────────
  Widget _buildRatingSection() {
    return _buildSection(
      title: 'Beri rating produk ini',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => _controller.goToTulisReview(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Icon(Icons.star_border,
                      color: Color(0xFFFFC107), size: 34),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _controller.goToTulisReview(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Tulis Ulasan',
              style: TextStyle(color: Color(0xFF2ECC71), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Review Section ────────────────────────────────────────
  Widget _buildReviewSection() {
    final reviews = _controller.displayedReviews;
    final totalReviews = _controller.reviewList.length;
    final avgRating = totalReviews > 0
        ? _controller.reviewList
                .map((r) => r.rating)
                .reduce((a, b) => a + b) /
            totalReviews
        : 0.0;

    return _buildSection(
      title: 'Ulasan Produk',
      trailing: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 18),
          const SizedBox(width: 4),
          Text(
            avgRating.toStringAsFixed(1),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E)),
          ),
          Text(
            ' ($totalReviews ulasan)',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
      child: _controller.isLoadingReviews
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
              ),
            )
          : reviews.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 40, color: Color(0xFFB0B0C3)),
                        SizedBox(height: 8),
                        Text('Belum ada ulasan',
                            style: TextStyle(
                                color: Color(0xFF9E9E9E), fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...reviews.map((r) => _ReviewItem(review: r)),
                    if (totalReviews >
                        KamarDetailController.maxDisplayedReviews)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: _controller.toggleShowAllReviews,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF2ECC71)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _controller.showAllReviews
                                      ? 'Tampilkan lebih sedikit'
                                      : 'Lihat ${totalReviews - KamarDetailController.maxDisplayedReviews} ulasan lainnya',
                                  style: const TextStyle(
                                      color: Color(0xFF2ECC71),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                Icon(
                                  _controller.showAllReviews
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF2ECC71),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _controller.goToSemuaReview(context),
                      child: const Text(
                        'Lihat Semua Ulasan Produk',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF2ECC71),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    final tersedia = _controller.kamar!.tersedia;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x15000000),
              blurRadius: 12,
              offset: Offset(0, -3)),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: tersedia ? () => _onPesanSekarang() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                tersedia ? const Color(0xFF2ECC71) : const Color(0xFFB0B0C3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            tersedia ? 'Pesan Sekarang' : 'Kamar Tidak Tersedia',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _onPesanSekarang() {
    final error = _controller.validateBooking();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    _showBookingBottomSheet();
  }

  void _showBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingBottomSheet(controller: _controller),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Color(0xFFB0B0C3)),
          const SizedBox(height: 12),
          Text(_controller.errorMessage!,
              style: const TextStyle(color: Color(0xFF9E9E9E))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.init,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ══════════════════════════════════════════════════════════════
// Bottom Sheet Booking + Pilih Furnitur
// ══════════════════════════════════════════════════════════════
class _BookingBottomSheet extends StatefulWidget {
  final KamarDetailController controller;
  const _BookingBottomSheet({required this.controller});

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  KamarDetailController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final kamar = c.kamar!;

    // Pisahkan furnitur tersedia dan habis
    final furniturTersedia = c.furniturList.where((f) => f.jumlah > 0).toList();
    final furniturHabis    = c.furniturList.where((f) => f.jumlah <= 0).toList();
    final allFurnitur      = [...furniturTersedia, ...furniturHabis];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header info kamar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kamar.fotoPrimary != null
                      ? Image.network(
                          kamar.fotoPrimary!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _miniPlaceholder(),
                        )
                      : _miniPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kos ${_cap(kamar.tipeKamar)} ${kamar.nomorKamar}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Lama sewa: ${c.durasiSewa} Bulan',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                      if (c.tglMulaiSewa != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${c.formatTanggal(c.tglMulaiSewa)} → ${c.formatTanggal(c.tglAkhirSewa)}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF2ECC71)),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        c.formatHarga(c.totalBiaya),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Judul + info stok
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Penambahan Furnitur',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                // Badge jumlah item tersedia
                if (furniturTersedia.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${furniturTersedia.length} tersedia',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List furnitur
          if (allFurnitur.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('Tidak ada furnitur tersedia',
                    style: TextStyle(
                        color: Color(0xFF9E9E9E), fontSize: 13)),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allFurnitur.length,
                itemBuilder: (_, index) {
                  final f    = allFurnitur[index];
                  final habis = f.jumlah <= 0;
                  final qty  = c.getFurniturQty(f.idFurnitur);
                  return _FurniturItem(
                    furnitur   : f,
                    qty        : qty,
                    isHabis    : habis,
                    onTambah   : habis || qty >= f.jumlah
                        ? null
                        : () {
                            c.tambahFurnitur(f.idFurnitur);
                            setState(() {});
                          },
                    onKurang   : qty > 0
                        ? () {
                            c.kurangFurnitur(f.idFurnitur);
                            setState(() {});
                          }
                        : null,
                    formatHarga: c.formatHarga,
                  );
                },
              ),
            ),

          const Divider(height: 16),

          // Total biaya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
                Text(
                  c.formatHarga(c.totalBiaya),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tombol Pesan
          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    c.goToBookingForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pesan Sekarang',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPlaceholder() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.bed_outlined,
            color: Color(0xFF2ECC71), size: 28),
      );

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ══════════════════════════════════════════════════════════════
// Furnitur Item Row — dengan info stok & disable jika habis
// ══════════════════════════════════════════════════════════════
class _FurniturItem extends StatelessWidget {
  final FurniturModel furnitur;
  final int qty;
  final bool isHabis;
  final VoidCallback? onTambah;
  final VoidCallback? onKurang;
  final String Function(double) formatHarga;

  const _FurniturItem({
    required this.furnitur,
    required this.qty,
    required this.isHabis,
    required this.onTambah,
    required this.onKurang,
    required this.formatHarga,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isHabis ? 0.45 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            // Icon furnitur
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isHabis
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair_outlined,
                color: isHabis
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF2ECC71),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),

            // Nama + harga + stok
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(furnitur.namaFurnitur,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 1),
                  Text(
                    '${formatHarga(furnitur.hargaSewaTambahan)}/bulan',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(height: 2),
                  // ── Info stok ──────────────────────────────
                  Row(
                    children: [
                      Icon(
                        isHabis
                            ? Icons.do_not_disturb_alt_outlined
                            : Icons.inventory_2_outlined,
                        size: 10,
                        color: isHabis
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF2ECC71),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isHabis
                            ? 'Stok habis'
                            : 'Tersedia: ${furnitur.jumlah}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isHabis
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Qty counter — disabled jika habis
            Row(
              children: [
                _CounterBtn(
                  icon: Icons.remove,
                  onTap: onKurang,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    qty.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                  ),
                ),
                _CounterBtn(
                  icon: Icons.add,
                  onTap: onTambah, // null jika habis atau sudah max
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF2ECC71)
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap != null ? Colors.white : const Color(0xFFB0B0C3)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Review Item
// ══════════════════════════════════════════════════════════════
class _ReviewItem extends StatelessWidget {
  final ReviewModel review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2ECC71).withOpacity(0.2),
            child: Text(
              review.namaUser.isNotEmpty
                  ? review.namaUser[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.namaUser,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 3),
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 13,
                              color: const Color(0xFFFFC107),
                            )),
                    const SizedBox(width: 6),
                    Text(review.tglReview,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9E9E9E))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(review.komentar,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}