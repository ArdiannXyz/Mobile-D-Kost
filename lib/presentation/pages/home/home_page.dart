import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_controller.dart';
import 'package:dkost/presentation/widgets/kamar_card.dart';
import 'package:dkost/presentation/pages/review_keluhan/keluhan_page.dart';
import 'package:dkost/presentation/pages/tagihan/tagihan_page.dart';
import 'package:dkost/presentation/pages/profil_setting/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  int _currentNavIndex = 0;

  // Track tab mana yang sudah pernah dibuka
  final Set<int> _visitedTabs = {0}; // Tab 0 langsung load

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
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Tab 0: Dashboard — selalu load
          _DashboardTab(controller: _controller),

          // Tab 1: Keluhan — lazy load
          _visitedTabs.contains(1)
              ? const KeluhanListPage()
              : const SizedBox.shrink(),

          // Tab 2: Tagihan — lazy load
          _visitedTabs.contains(2)
              ? const TagihanPage()
              : const SizedBox.shrink(),

          // Tab 3: Setting — lazy load
          _visitedTabs.contains(3)
              ? const SettingPage()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      ['assets/images/home_green.png', 'assets/images/home_black.png'],
      ['assets/images/keluhan_green.png', 'assets/images/keluhan_black.png'],
      ['assets/images/kamarku_green.png', 'assets/images/kamarku_black.png'],
      ['assets/images/setting_green.png', 'assets/images/setting_black.png'],
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
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
                    setState(() {
                      _currentNavIndex = index;
                      _visitedTabs.add(index);
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Image.asset(
                      isActive ? items[index][0] : items[index][1],
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(
                        [
                          Icons.home_outlined,
                          Icons.report_problem_outlined,
                          Icons.receipt_long_outlined,
                          Icons.settings_outlined,
                        ][index],
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

// ══════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ══════════════════════════════════════════════════════════════
class _DashboardTab extends StatefulWidget {
  final HomeController controller;
  const _DashboardTab({required this.controller});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  // Daftar banner SVG — tambahkan lebih banyak sesuai kebutuhan
  static const List<String> _banners = [
    'assets/images/Asset_2.png',
    'assets/images/Asset_4.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
    }
    if (widget.controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 12),
            Text(widget.controller.errorMessage!,
                style: const TextStyle(color: Color(0xFF9E9E9E))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.controller.refresh,
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
      onRefresh: widget.controller.refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          SliverToBoxAdapter(child: _buildBannerSlider(context)),
          SliverToBoxAdapter(child: _buildRekomendasi(context)),
          SliverToBoxAdapter(child: _buildFilterChips(context)),
          widget.controller.filteredKamar.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final kamar = widget.controller.filteredKamar[index];
                        return KamarCard(
                          kamar: kamar,
                          mode: KamarCardMode.grid,
                          onTap: () => widget.controller
                              .goToKamarDetail(ctx, kamar.idKamar),
                        );
                      },
                      childCount: widget.controller.filteredKamar.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: const Color(0xFF2ECC71),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: GestureDetector(
        onTap: () => widget.controller.goToSearch(context),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
              SizedBox(width: 8),
              Text('Cari kamar kost...',
                  style: TextStyle(color: Color(0xFFB0B0C3), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner Slider ──────────────────────────────────────────
  Widget _buildBannerSlider(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          // PageView banner
          ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 140,
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: 1.1, // ← makin kecil, makin keliatan banner sebelah
                  ),
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() => _currentBannerIndex = index);
                  },
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6), // ← jarak antar banner
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16), // ← rounded per banner
                      child: Image.asset(
                        _banners[index],
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF27AE60),
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          

          const SizedBox(height: 10),

          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              final isActive = index == _currentBannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.lightGreen : Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Rekomendasi ────────────────────────────────────────────
  Widget _buildRekomendasi(BuildContext context) {
    final tersedia = widget.controller.semuaKamar
        .where((k) => k.statusKamar == 'tersedia')
        .take(5)
        .toList();
    if (tersedia.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('Rekomendasi Kamar',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tersedia.length,
            itemBuilder: (ctx, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 160,
                child: KamarCard(
                  kamar: tersedia[index],
                  mode: KamarCardMode.horizontal,
                  onTap: () => widget.controller
                      .goToKamarDetail(ctx, tersedia[index].idKamar),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Chips ───────────────────────────────────────────
  Widget _buildFilterChips(BuildContext context) {
    const filters = ['Semua', 'Serba 300rb', 'Serba 600rb', 'Up to 900rb'];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final isSelected =
              widget.controller.selectedFilter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[i]),
              selected: isSelected,
              onSelected: (_) =>
                  widget.controller.applyFilter(filters[i]),
              selectedColor: const Color(0xFF2ECC71),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF555555),
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFE0E0E0),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
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
}