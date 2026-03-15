// ============================================================
// FRONTEND LAYER — tulis_review_page.dart
// Sesuai Figma: AppBar hijau "Berikan Ulasan", 5 bintang
// interaktif, textarea komentar, tombol hijau "Posting".
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
      onStateChanged: () { if (mounted) setState(() {}); },
    );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => _controller.goBack(context),
        ),
        centerTitle: true,
        title: const Text('Berikan Ulasan',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildStarRating(),
                  const SizedBox(height: 24),
                  _buildKomentarField(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => GestureDetector(
          onTap: () => _controller.setRating(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              i < _controller.selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 38,
              color: const Color(0xFFFFC107),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildKomentarField() {
    return TextField(
      controller: _controller.komentarController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: 'Deskripsikan Pengalaman Anda',
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
          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _controller.isSubmitting ? null : () => _controller.submit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            disabledBackgroundColor: const Color(0xFF2ECC71).withOpacity(0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _controller.isSubmitting
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Posting',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}