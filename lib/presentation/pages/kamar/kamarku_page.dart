// ============================================================
// FILE: lib/presentation/pages/kamarku/kamarku_page.dart
// ============================================================

import 'package:dkost/data/helper/api_constants.dart';
import 'package:flutter/material.dart';
import 'kamarku_controller.dart';

class KamarkuPage extends StatefulWidget {
  const KamarkuPage({super.key});

  @override
  State<KamarkuPage> createState() => _KamarkuPageState();
}

class _KamarkuPageState extends State<KamarkuPage> {
  late final KamarkuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KamarkuController(
      onStateChanged: () { if (mounted) setState(() {}); },
    );
    _controller.loadBookings();
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
    return Container(
      color: const Color(0xFF1BBA8A),
      width: double.infinity,
      padding: EdgeInsets.only(
        top   : MediaQuery.of(context).padding.top + 12,
        bottom: 16,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: GestureDetector(
              onTap : () => Navigator.pop(context),
              child : const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const Text(
            'Kamarku',
            style: TextStyle(
              color     : Colors.white,
              fontSize  : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1BBA8A)));
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
                onPressed: _controller.loadBookings,
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

    if (_controller.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bed_outlined,
                size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 14),
            const Text('Tidak ada kamar aktif',
                style: TextStyle(
                    color: Color(0xFF9E9E9E), fontSize: 14)),
            const SizedBox(height: 6),
            const Text('Temukan kamar kost impianmu!',
                style: TextStyle(
                    color: Color(0xFFB0B0C3), fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color    : const Color(0xFF1BBA8A),
      onRefresh: _controller.loadBookings,
      child: ListView.builder(
        padding   : const EdgeInsets.all(16),
        itemCount : _controller.bookings.length,
        itemBuilder: (context, index) {
          final booking = _controller.bookings[index];
          return _BookingCard(
            booking   : booking,
            controller: _controller,
            onTap     : () => _controller.goToDetail(context, booking.idBooking),
          );
        },
      ),
    );
  }
}

// ── Booking Card ───────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final booking;
  final KamarkuController controller;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bangun URL foto yang benar via controller

    return Container(
      margin    : const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0A000000),
              blurRadius: 6,
              offset    : Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto kamar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: booking.fotoKamar != null
                    ? Image.network(
                        booking.fotoKamar!.startsWith('http')
                            ? booking.fotoKamar!
                            : '${ApiConstants.storageUrl}${booking.fotoKamar!}',
                        width       : 80,
                        height      : 80,
                        fit         : BoxFit.cover,
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
                        'Kos ${_cap(booking.tipeKamar ?? '')} ${booking.nomorKamar ?? ''}',
                        style: const TextStyle(
                          fontSize  : 14,
                          fontWeight: FontWeight.bold,
                          color     : Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.formatTanggal(booking.tglMulaiSewa)} - '
                        '${controller.formatTanggal(booking.tglAkhirSewa)}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.formatHarga(booking.totalBiayaBulanan),
                        style: const TextStyle(
                          fontSize  : 14,
                          fontWeight: FontWeight.bold,
                          color     : Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: controller
                              .statusColor(booking.statusBooking)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          controller.statusLabel(booking.statusBooking),
                          style: TextStyle(
                            fontSize  : 11,
                            fontWeight: FontWeight.w600,
                            color     : controller.statusColor(booking.statusBooking),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          InkWell(
            onTap       : onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft : Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize  : 13,
                      fontWeight: FontWeight.w600,
                      color     : Color(0xFF1BBA8A),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Color(0xFF1BBA8A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
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

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}