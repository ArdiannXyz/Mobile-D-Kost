// ============================================================
// FRONTEND LAYER — search_page.dart
// Halaman pencarian kamar D'Kost.
// Mode suggestion: riwayat + kata kunci populer
// ============================================================

import 'package:flutter/material.dart';
import 'search_controller.dart' as sc;
import 'package:dkost/presentation/widgets/kamar_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late sc.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sc.SearchController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init().then((_) {
      if (mounted) {
        _controller.searchFocusNode.requestFocus();
      }
    });
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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1BBA8A)))
                : _controller.currentMode == sc.SearchMode.suggestion
                    ? _buildSuggestionView()
                    : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1BBA8A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 8,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _controller.goBack(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller.searchTextController,
                focusNode: _controller.searchFocusNode,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Cari nomor atau tipe kamar...',
                  hintStyle: const TextStyle(
                      color: Color(0xFFBBBBBB), fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFFAAAAAA), size: 20),
                  suffixIcon: _controller
                          .searchTextController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: _controller.clearSearch,
                          child: const Icon(Icons.close,
                              color: Color(0xFFAAAAAA), size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onSubmitted: _controller.performSearch,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionView() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (_controller.searchSuggestions.isNotEmpty)
          _buildSuggestionList(),
        if (_controller.searchHistory.isNotEmpty)
          _buildHistorySection(),
        _buildPopularKeywords(),
        _buildPriceKeywords(),
      ],
    );
  }

  Widget _buildSuggestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Saran pencarian',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w600)),
        ),
        ..._controller.searchSuggestions.map((s) => ListTile(
              leading: const Icon(Icons.search,
                  color: Color(0xFF1BBA8A), size: 18),
              title: Text(s,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A2E))),
              dense: true,
              onTap: () => _controller.useSuggestion(s),
            )),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Riwayat pencarian',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Max ${sc.SearchController.maxHistoryLength}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1BBA8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _controller.clearHistory,
                child: const Text('Hapus semua',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1BBA8A),
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        ..._controller.searchHistory.map((h) => ListTile(
              leading: const Icon(Icons.history,
                  color: Color(0xFF9E9E9E), size: 18),
              title: Text(h,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A2E))),
              trailing: GestureDetector(
                onTap: () => _controller.removeFromHistory(h),
                child: const Icon(Icons.close,
                    size: 16, color: Color(0xFFB0B0C3)),
              ),
              dense: true,
              onTap: () => _controller.useSuggestion(h),
            )),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildPopularKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('Kata kunci populer',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sc.SearchController.popularKeywords.map((k) {
              return GestureDetector(
                onTap: () => _controller.useSuggestion(k),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Text(k,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPriceKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('Cari berdasarkan harga',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPriceChip(
                label: 'Harga < Rp 400.000',
                keyword: 'harga dibawah 400rb',
                icon: Icons.money_off,
              ),
              _buildPriceChip(
                label: 'Harga < Rp 700.000',
                keyword: 'harga dibawah 700rb',
                icon: Icons.attach_money,
              ),
              _buildPriceChip(
                label: 'Rp 400k - Rp 700k',
                keyword: 'harga 400rb sampai 700rb',
                icon: Icons.compare_arrows,
              ),
              _buildPriceChip(
                label: 'Rp 700k - Rp 1jt',
                keyword: 'harga 700rb sampai 1jt',
                icon: Icons.trending_up,
              ),
              _buildPriceChip(
                label: 'Harga > Rp 1.000.000',
                keyword: 'harga diatas 1jt',
                icon: Icons.king_bed,
              ),
              _buildPriceChip(
                label: 'Kamar termurah',
                keyword: 'termurah',
                icon: Icons.arrow_downward,
                color: const Color(0xFF4CAF50),
              ),
              _buildPriceChip(
                label: 'Kamar termahal',
                keyword: 'termahal',
                icon: Icons.arrow_upward,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPriceChip({
    required String label,
    required String keyword,
    required IconData icon,
    Color color = const Color(0xFF1BBA8A),
  }) {
    return GestureDetector(
      onTap: () => _controller.useSuggestion(keyword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text:
                            '${_controller.searchResults.length} kamar',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      TextSpan(
                        text:
                            ' untuk "${_controller.currentQuery}"',
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _controller.clearSearch,
                child: const Text('Ubah',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1BBA8A),
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _controller.searchResults.isEmpty
              ? _buildEmptyResults()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.searchResults.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: _cardAspectRatio(context),
                  ),
                  itemBuilder: (context, index) {
                    final kamar = _controller.searchResults[index];
                    return KamarCard(
                      kamar: kamar,
                      mode: KamarCardMode.grid,
                      onTap: () =>
                          _controller.goToDetail(context, kamar.idKamar),
                    );
                  },
                ),
        ),
      ],
    );
  }

  double _cardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 14) / 2;
    final photoHeight = cardWidth * (14 / 16);
    const infoHeight = 100.0;
    return cardWidth / (photoHeight + infoHeight);
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kamar untuk\n"${_controller.currentQuery}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _controller.clearSearch,
              child: const Text('Coba kata kunci lain',
                  style: TextStyle(color: Color(0xFF1BBA8A))),
            ),
          ],
        ),
      ),
    );
  }
}