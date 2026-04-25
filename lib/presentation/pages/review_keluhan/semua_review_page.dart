// ============================================================
// FRONTEND LAYER — semua_review_page.dart
// Sesuai Figma: AppBar hijau "Semua Ulasan", filter chips
// rating (Semua, 1★–5★), list kartu ulasan dengan avatar,
// nama, bintang, dan komentar.
// ============================================================

import 'package:flutter/material.dart';
import 'review_controller.dart';

class SemuaReviewPage extends StatefulWidget {
  final int kamarId;
  const SemuaReviewPage({super.key, required this.kamarId});

  @override
  State<SemuaReviewPage> createState() => _SemuaReviewPageState();
}

class _SemuaReviewPageState extends State<SemuaReviewPage> {
  late final SemuaReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SemuaReviewController(
      kamarId: widget.kamarId,
      onStateChanged: () { if (mounted) setState(() {}); },
    );
    _controller.loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1BBA8A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => _controller.goBack(context),
      ),
      centerTitle: true,
      title: const Text('Semua Ulasan',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1BBA8A)));
    }
    if (_controller.errorMessage != null) {
      return Center(child: Text(_controller.errorMessage!,
          style: const TextStyle(color: Color(0xFF9E9E9E))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        _buildFilterChips(),
        // Label "Semua" + jumlah
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                _controller.selectedRating == null
                    ? 'Semua'
                    : '${_controller.selectedRating} Bintang',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(width: 6),
              Text('(${_controller.filteredReviews.length})',
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
            ],
          ),
        ),
        // List ulasan
        Expanded(
          child: _controller.filteredReviews.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rate_review_outlined, size: 56, color: Color(0xFFB0B0C3)),
                      SizedBox(height: 12),
                      Text('Belum ada ulasan', style: TextStyle(color: Color(0xFF9E9E9E))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _controller.filteredReviews.length,
                  itemBuilder: (_, i) =>
                      _ReviewCard(review: _controller.filteredReviews[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Semua', null),
            ...List.generate(5, (i) => _chip('${5 - i} ★', 5 - i)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int? rating) {
    final isSelected = _controller.selectedRating == rating;
    return GestureDetector(
      onTap: () => _controller.filterByRating(rating),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1BBA8A) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF555555),
            )),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1BBA8A).withOpacity(0.15),
            child: Text(
              review.namaUser.isNotEmpty ? review.namaUser[0].toUpperCase() : 'U',
              style: const TextStyle(color: Color(0xFF1BBA8A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.namaUser,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14, color: const Color(0xFFFFC107),
                  )),
                ),
                const SizedBox(height: 6),
                Text(review.komentar,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}