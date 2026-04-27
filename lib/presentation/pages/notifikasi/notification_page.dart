import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// MODEL NOTIFIKASI
// ══════════════════════════════════════════════════════════════
class NotifikasiItem {
  final String id;
  final String judul;
  final String pesan;
  final NotifikasiTipe tipe;
  bool sudahDibaca;
  final DateTime waktu;

  NotifikasiItem({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    this.sudahDibaca = false,
    required this.waktu,
  });
}

enum NotifikasiTipe { tagihan, keluhan, umum }

// ══════════════════════════════════════════════════════════════
// NOTIFIKASI MANAGER (Simple state management)
// ══════════════════════════════════════════════════════════════
class NotifikasiManager {
  static final NotifikasiManager _instance = NotifikasiManager._internal();
  factory NotifikasiManager() => _instance;
  NotifikasiManager._internal();

  final List<NotifikasiItem> _items = [
    NotifikasiItem(
      id: '1',
      judul: 'Reminder Tagihan',
      pesan:
          'Anda memiliki tagihan yang akan jatuh tempo pada tanggal 22 - 04 - 2026, Segera lakukan perpanjangan sewa',
      tipe: NotifikasiTipe.tagihan,
      sudahDibaca: false,
      waktu: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotifikasiItem(
      id: '2',
      judul: 'Status Keluhan',
      pesan:
          'keluhan anda telah diproses oleh admin dan akan segera dilakukan tindakan',
      tipe: NotifikasiTipe.keluhan,
      sudahDibaca: false,
      waktu: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<NotifikasiItem> get semua => List.unmodifiable(_items);
  List<NotifikasiItem> get belumDibaca =>
      _items.where((e) => !e.sudahDibaca).toList();
  List<NotifikasiItem> get sudahDibaca =>
      _items.where((e) => e.sudahDibaca).toList();
  int get jumlahBelumDibaca => belumDibaca.length;

  void tandaiDibaca(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) _items[idx].sudahDibaca = true;
  }

  void tandaiSemuaDibaca() {
    for (final item in _items) {
      item.sudahDibaca = true;
    }
  }

  void tambah(NotifikasiItem item) => _items.insert(0, item);
}

// ══════════════════════════════════════════════════════════════
// HALAMAN NOTIFIKASI
// ══════════════════════════════════════════════════════════════
class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _manager = NotifikasiManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTap(NotifikasiItem item) {
    _manager.tandaiDibaca(item.id);
    setState(() {});

    // Navigasi berdasarkan tipe
    if (item.tipe == NotifikasiTipe.tagihan) {
      // Kembali ke home lalu arahkan ke tab tagihan (index 2)
      Navigator.pop(context, 'tagihan');
    } else if (item.tipe == NotifikasiTipe.keluhan) {
      // Kembali ke home lalu arahkan ke tab keluhan (index 1)
      Navigator.pop(context, 'keluhan');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final belumDibaca = _manager.belumDibaca;
    final sudahDibaca = _manager.sudahDibaca;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── AppBar Custom ──────────────────────────────────
          _buildAppBar(context, belumDibaca.length),

          // ── Tab Content ────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(belumDibaca, isBelumDibaca: true),
                _buildList(sudahDibaca, isBelumDibaca: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int belumDibacaCount) {
    return Container(
      color: const Color(0xFF1BBA8A),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row: back + title + mark all
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifikasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Tombol tandai semua (opsional)
                  if (belumDibacaCount > 0)
                    TextButton(
                      onPressed: () {
                        _manager.tandaiSemuaDibaca();
                        setState(() {});
                      },
                      child: const Text(
                        'Baca semua',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Custom Tab Bar ─────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Belum dibaca', belumDibacaCount),
                  _buildTab(1, 'Dibaca', null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, int? badgeCount) {
    final isActive = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF1BBA8A)
                      : Colors.white,
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1BBA8A)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<NotifikasiItem> items, {required bool isBelumDibaca}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBelumDibaca
                  ? Icons.notifications_none_rounded
                  : Icons.done_all_rounded,
              size: 60,
              color: const Color(0xFFB0B0C3),
            ),
            const SizedBox(height: 12),
            Text(
              isBelumDibaca
                  ? 'Tidak ada notifikasi baru'
                  : 'Belum ada notifikasi dibaca',
              style: const TextStyle(
                  color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, index) => _buildNotifCard(items[index]),
    );
  }

  Widget _buildNotifCard(NotifikasiItem item) {
    return GestureDetector(
      onTap: () => _handleTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !item.sudahDibaca
                ? const Color(0xFF1BBA8A).withOpacity(0.4)
                : const Color(0xFFE8E8E8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──────────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1BBA8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(item.tipe),
                color: const Color(0xFF1BBA8A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ── Teks ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.sudahDibaca
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: const Color(0xFF1BBA8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.pesan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Dot belum dibaca ──────────────────────────
            if (!item.sudahDibaca) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1BBA8A),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon(NotifikasiTipe tipe) {
    switch (tipe) {
      case NotifikasiTipe.tagihan:
        return Icons.receipt_long_rounded;
      case NotifikasiTipe.keluhan:
        return Icons.person_outline_rounded;
      case NotifikasiTipe.umum:
        return Icons.notifications_outlined;
    }
  }
}