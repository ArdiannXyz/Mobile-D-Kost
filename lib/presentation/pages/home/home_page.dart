// ============================================================
// FRONTEND LAYER — home_page.dart
// Sesuai screenshot: search bar hijau, banner biru-hijau
// dengan awan & matahari, rekomendasi horizontal (dengan tombol),
// filter chips, grid 2 kolom (tanpa tombol).
// Bottom nav: 4 icon PNG dari assets, tanpa label.
// ============================================================

import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'package:dkost/presentation/widgets/kamar_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
    }
    if (_controller.errorMessage != null) {
      return Center(
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
              onPressed: _controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2ECC71),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildRekomendasi()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _controller.filteredKamar.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final kamar = _controller.filteredKamar[index];
                        return KamarCard(
                          kamar: kamar,
                          mode: KamarCardMode.grid,
                          onTap: () => _controller.goToKamarDetail(
                              context, kamar.idKamar),
                        );
                      },
                      childCount: _controller.filteredKamar.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF2ECC71),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: GestureDetector(
        onTap: () => _controller.goToSearch(context),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
              SizedBox(width: 10),
              Text('Search',
                  style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner biru dengan awan & matahari ────────────────────
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF42A5F5), Color(0xFF29B6F6), Color(0xFF4DD0E1)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Matahari kuning pojok kanan atas
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFDD835),
              ),
            ),
          ),
          // Highlight matahari
          Positioned(
            right: 22,
            top: -4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ),
          // Awan besar kanan
          Positioned(
            right: 14,
            top: 46,
            child: _cloud(64, 24),
          ),
          // Awan kecil kanan bawah
          Positioned(
            right: 52,
            bottom: 10,
            child: _cloud(46, 18),
          ),
          // Awan kecil kanan tengah
          Positioned(
            right: 90,
            top: 14,
            child: _cloud(36, 15),
          ),
          // Teks
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 130, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi ${_controller.userName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'selamat datang',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cloud(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(h / 2),
        ),
      );

  // ── Rekomendasi (horizontal, dengan tombol Detail Kamar) ───
  Widget _buildRekomendasi() {
    final list = _controller.semuaKamar
        .where((k) => k.tersedia)
        .take(6)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Text(
            'Rekomendasi kamar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        SizedBox(
          height: 215,
          child: list.isEmpty
              ? const Center(
                  child: Text('Belum ada kamar tersedia',
                      style: TextStyle(color: Color(0xFF9E9E9E))))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final kamar = list[index];
                    return SizedBox(
                      width: 148,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: KamarCard(
                          kamar: kamar,
                          mode: KamarCardMode.horizontal,
                          onTap: () => _controller.goToKamarDetail(
                              context, kamar.idKamar),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────────────────
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: HomeController.filterOptions.map((filter) {
            final isSelected = _controller.selectedFilter == filter;
            return GestureDetector(
              onTap: () => _controller.applyFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFE0E0E0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2ECC71).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bed_outlined, size: 56, color: Color(0xFFB0B0C3)),
            SizedBox(height: 12),
            Text('Tidak ada kamar ditemukan',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      ['assets/images/home green (2).png', 'assets/images/home black (2).png'],
      ['assets/images/person 1.png', 'assets/images/person 2.png'],
      ['assets/images/kamarku green.png', 'assets/images/kamarku black.png'],
      ['assets/images/setting green.png', 'assets/images/setting black.png'],
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(4, (index) {
              final isActive = _currentNavIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentNavIndex = index);
                    if (index == 1) {
                      _controller.goToKeluhan(context);
                      setState(() => _currentNavIndex = 0);
                    } else if (index == 2) {
                      _controller.goToRiwayatKos(context);
                      setState(() => _currentNavIndex = 0);
                    } else if (index == 3) {
                      _controller.goToSetting(context);
                      setState(() => _currentNavIndex = 0);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Image.asset(
                      isActive ? items[index][0] : items[index][1],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(
                        [Icons.home_outlined, Icons.person_outline,
                         Icons.bed_outlined, Icons.settings_outlined][index],
                        color: isActive
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFF9E9E9E),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}