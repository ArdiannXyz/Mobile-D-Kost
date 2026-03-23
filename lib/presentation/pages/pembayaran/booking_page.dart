// ============================================================
// FRONTEND LAYER — booking_form_page.dart
// Halaman konfirmasi checkout setelah pilih kamar + furnitur
// ============================================================

import 'package:flutter/material.dart';
import 'booking_controller.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
late final BookingController _controller;
  bool _initialized = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : _buildBody(),
      bottomNavigationBar: _controller.isLoading ? null : _buildBottomBar(),
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
                            _controller.formatHarga(_controller.hargaPerBulan),
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

          // ── Info ─────────────────────────────────────────
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

  // ── Bottom Bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
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
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _controller.isSubmitting
              ? null
              : () => _controller.konfirmasi(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            disabledBackgroundColor:
                const Color(0xFF2ECC71).withOpacity(0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _controller.isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Konfirmasi & Bayar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  // ── Widget Helpers ────────────────────────────────────────
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
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
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