// ============================================================
// FILE: lib/presentation/pages/review/tulis_review_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'review_controller.dart';

class TulisReviewPage extends StatefulWidget {
  final int kamarId;
  const TulisReviewPage({super.key, required this.kamarId});

  @override
  State<TulisReviewPage> createState() => _TulisReviewPageState();
}

class _TulisReviewPageState extends State<TulisReviewPage> {
  late final TulisReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TulisReviewController(
      kamarId: widget.kamarId,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.initForm(); // ← cek booking aktif saat init
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => _controller.goBack(context),
        ),
        centerTitle: true,
        title: const Text('Berikan Ulasan',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_controller.pageState) {
      // ── Loading ──────────────────────────────────────────
      case ReviewPageState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
        );

      // ── Tidak punya booking aktif ─────────────────────────
      case ReviewPageState.noBooking:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFFB0B0C3), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak dapat memberikan ulasan',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hanya penghuni kamar ini yang dapat memberikan ulasan.',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );

      // ── Punya booking aktif → tampilkan form ──────────────
      case ReviewPageState.hasBooking:
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildInfoKamar(),
                    const SizedBox(height: 16),
                    _buildStarRating(),
                    const SizedBox(height: 16),
                    _buildKomentarField(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        );
    }
  }

  // ── Info kamar aktif (opsional, memberi konteks ke user) ──
  Widget _buildInfoKamar() {
    final booking = _controller.bookingAktif;
    if (booking == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB7EBCF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.meeting_room_outlined,
              color: Color(0xFF2ECC71), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kamar ${booking.nomorKamar ?? '-'} · ${booking.tipeKamar ?? '-'}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A6B3C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('Seberapa puas Anda?',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => _controller.setRating(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _controller.selectedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 38,
                    color: const Color(0xFFFFC107),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKomentarField() {
    return TextField(
      controller: _controller.komentarController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: 'Deskripsikan pengalaman Anda...',
        hintStyle: const TextStyle(color: Color(0xFFB0B0C3)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _controller.isSubmitting
              ? null
              : () => _controller.submit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            disabledBackgroundColor:
                const Color(0xFF2ECC71).withOpacity(0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _controller.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Posting',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}