// ============================================================
// booking_form_page.dart  (updated)
// Tambahan: selector metode pembayaran + integrasi ke PaymentService
// ============================================================

import 'package:flutter/material.dart';
import 'booking_controller.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/services/payment_service.dart';
import '../pembayaran/pembayaran_instruksi_page.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  late final BookingController _controller;
  bool _initialized = false;

  // ── State metode pembayaran ────────────────────────────────
  PaymentMethodType? _selectedMethod;
  bool _isProcessingPayment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
      _controller = BookingController(
        args: args,
        onStateChanged: () {
          if (mounted) setState(() {});
        },
      );
      _controller.init();
    }
  }

  // ── Aksi: Konfirmasi + langsung bayar ─────────────────────
  Future<void> _konfirmasiDanBayar() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      // 1. Buat booking dulu (pakai method konfirmasi yang sudah ada)
      //    konfirmasi() harus return idTagihan — lihat catatan di bawah
      final idTagihan = await _controller.konfirmasiReturnTagihan(context);

      if (idTagihan == null || !mounted) return;

      // 2. Langsung charge ke Midtrans dengan metode yang dipilih
      final paymentResult = await PaymentService.createPayment(
        idTagihan : idTagihan,
        method    : _selectedMethod!,
      );

      if (!mounted) return;

      // 3. Navigasi ke halaman instruksi pembayaran
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentInstructionPage(
            result    : paymentResult,
            idTagihan : idTagihan,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : _buildBody(),
      bottomNavigationBar:
          _controller.isLoading ? null : _buildBottomBar(),
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
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Konfirmasi Booking',
        style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info Kamar ──────────────────────────────────
          _buildCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _controller.kamar?.fotoPrimary != null
                      ? Image.network(
                          _controller.kamar!.fotoPrimary!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoPlaceholder(),
                        )
                      : _photoPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controller.namaKamar,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildChip(
                        icon: Icons.hotel_outlined,
                        label: _controller.tipeKamar,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _controller.formatHarga(
                                _controller.hargaPerBulan),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                          const Text(
                            '/Bulan',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Detail Sewa ─────────────────────────────────
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Detail Sewa'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Mulai Sewa',
                  value: _controller.tglMulaiFormatted,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.event_outlined,
                  label: 'Akhir Sewa',
                  value: _controller.tglAkhirFormatted,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Durasi',
                  value: '${_controller.durasi} Bulan',
                ),
              ],
            ),
          ),

          // ── Furnitur Tambahan ────────────────────────────
          if (_controller.selectedFurniturList.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Furnitur Tambahan'),
                  const SizedBox(height: 12),
                  ..._controller.selectedFurniturList.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chair_outlined,
                                color: Color(0xFF2ECC71), size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${item['nama']} x${item['qty']}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1A2E)),
                            ),
                          ),
                          Text(
                            _controller.formatHarga(
                                (item['subtotal'] as num).toDouble()),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A2E)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Ringkasan Biaya ──────────────────────────────
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Ringkasan Biaya'),
                const SizedBox(height: 12),
                _buildBiayaRow(
                  label: 'Biaya kamar (${_controller.durasi} bln)',
                  value: _controller
                      .formatHarga(_controller.totalBiayaKamar),
                ),
                if (_controller.totalBiayaFurnitur > 0) ...[
                  const SizedBox(height: 6),
                  _buildBiayaRow(
                    label: 'Biaya furnitur',
                    value: _controller
                        .formatHarga(_controller.totalBiayaFurnitur),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                    Text(
                      _controller.formatHarga(_controller.totalBiaya),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ════════════════════════════════════════════════
          // ── METODE PEMBAYARAN (BARU) ─────────────────────
          // ════════════════════════════════════════════════
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Metode Pembayaran'),
                const SizedBox(height: 12),

                // ── Group: Transfer Bank ─────────────────
                _buildGroupLabel('Transfer Bank'),
                const SizedBox(height: 6),
                _buildMethodRow(PaymentMethodType.bcaVa),
                _buildMethodRow(PaymentMethodType.bniVa),
                _buildMethodRow(PaymentMethodType.briVa),
                _buildMethodRow(PaymentMethodType.mandiriVa),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),

                // ── Group: QRIS ──────────────────────────
                _buildGroupLabel('QRIS'),
                const SizedBox(height: 6),
                _buildMethodRow(PaymentMethodType.qris),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),

                // ── Group: Dompet Digital ────────────────
                _buildGroupLabel('Dompet Digital'),
                const SizedBox(height: 6),
                _buildMethodRow(PaymentMethodType.gopay),
                _buildMethodRow(PaymentMethodType.shopeepay),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Info syarat ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: Color(0xFFF39C12)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dengan melanjutkan, kamu menyetujui syarat dan ketentuan sewa kamar yang berlaku.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF795548),
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Widget: Group label ────────────────────────────────────
  Widget _buildGroupLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.black38,
        letterSpacing: 0.4,
      ),
    );
  }

  // ── Widget: Satu baris metode pembayaran ───────────────────
  Widget _buildMethodRow(PaymentMethodType method) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
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
                ? const Color(0xFF2ECC71)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Logo bank/metode
            SizedBox(
              width: 44,
              height: 28,
              child: Image.asset(
                _logoPath(method),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.account_balance,
                      size: 16, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Label
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

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2ECC71)
                      : Colors.grey[350]!,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF2ECC71)
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
  }

  // ── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLoading =
        _controller.isSubmitting || _isProcessingPayment;

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
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hint jika belum pilih metode
          if (_selectedMethod == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Pilih metode pembayaran di atas',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _konfirmasiDanBayar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                disabledBackgroundColor:
                    const Color(0xFF2ECC71).withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Konfirmasi & Bayar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (_selectedMethod != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedMethod!.label
                                  .replaceAll(' Virtual Account', ' VA'),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
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

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E)),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2ECC71)),
        const SizedBox(width: 8),
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildBiayaRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        Text(value,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF2ECC71)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.bed_outlined,
          color: Color(0xFF2ECC71), size: 32),
    );
  }
}