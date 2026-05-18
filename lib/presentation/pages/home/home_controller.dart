// ============================================================
// BACKEND LAYER — home_controller.dart
// Bertanggung jawab atas: load data kamar, data user,
// filter kamar by tipe, search, dan navigasi.
// Tidak boleh ada Widget/UI di sini.
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/helper/api_helper.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/models/kamar_models.dart';

class HomeController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  String? errorMessage;

  // ── Data ───────────────────────────────────────────────────
  String userName = 'Pengguna';
  List<KamarModel> semuaKamar = [];
  List<KamarModel> filteredKamar = [];
  String selectedFilter = 'Semua';

  // Filter chips sesuai ERD tipe_kamar
  static const List<String> filterOptions = [
    'Semua',
    'Tersedia',
    'Terisi',
    '>400rb',
    '>600rb',
    '>800rb',
  ];

  static const Map<String, String?> filterToStatus = {
    'Semua': null,
    'Tersedia': 'tersedia',
    'Terisi': 'terisi',
  };

  static const Map<String, double?> filterToHarga = {
    '>400rb': 400000,
    '>600rb': 600000,
    '>800rb': 800000,
  };

  final VoidCallback onStateChanged;

  HomeController({required this.onStateChanged});

  // ── Load Data (dengan cache) ────────────────────────────────
  // forceRefresh: true → paksa ambil dari API, abaikan cache
  // Dipanggil pertama kali saat initState → pakai cache jika ada
  // Dipanggil saat pull-to-refresh → forceRefresh: true
  Future<void> loadData({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();

      if (userId != null) {
        // Cek cache user dulu
        final userCacheKey = '${CacheService.keyUserPrefix}$userId';

        if (!forceRefresh) {
          final cachedName = CacheService.get<String>(userCacheKey);
          if (cachedName != null) {
            userName = cachedName;
          } else {
            await _fetchUserName(userId, userCacheKey);
          }
        } else {
          await _fetchUserName(userId, userCacheKey);
        }
      }

      // Load kamar — KamarService sudah handle cache internal
      final kamarList = await KamarService.getKamarList(
        forceRefresh: forceRefresh,
      );
      semuaKamar = kamarList;

      // Terapkan filter yang sedang aktif ke data baru
      _applyCurrentFilter();
    } catch (e) {
      errorMessage = 'Gagal memuat data. Tarik untuk refresh.';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Helper: Fetch & cache nama user ───────────────────────
  Future<void> _fetchUserName(int userId, String cacheKey) async {
    try {
      final user = await UserService.fetchUser(userId);
      if (user != null) {
        userName = user.nama;
        // Cache nama user 10 menit
        CacheService.set(cacheKey, userName, ttl: CacheService.ttlUser);
      }
    } catch (_) {
      userName = 'Pengguna';
    }
  }

  // ── Filter Kamar ───────────────────────────────────────────
  void applyFilter(String filterLabel) {
    selectedFilter = filterLabel;
    _applyCurrentFilter();
    onStateChanged();
  }

  void _applyCurrentFilter() {
    final status = filterToStatus[selectedFilter];
    final double? minHarga = filterToHarga[selectedFilter];

    if (status != null) {
      filteredKamar = semuaKamar.where((k) => k.statusKamar == status).toList();
    } else if (minHarga != null) {
      filteredKamar =
          semuaKamar.where((k) => k.hargaPerBulan >= minHarga).toList();
    } else {
      filteredKamar = List.from(semuaKamar); // 'Semua'
    }
  }

  // ── Search Kamar ───────────────────────────────────────────
  void searchKamar(String query) {
    if (query.isEmpty) {
      _applyCurrentFilter();
      onStateChanged();
      return;
    }

    final status = filterToStatus[selectedFilter];
    final minHarga = filterToHarga[selectedFilter];

    filteredKamar = semuaKamar.where((k) {
      final matchQuery =
          k.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
              k.tipeKamar.toLowerCase().contains(query.toLowerCase());
      final matchStatus = status == null || k.statusKamar == status;
      final matchHarga = minHarga == null || k.hargaPerBulan >= minHarga;
      return matchQuery && matchStatus && matchHarga;
    }).toList();
    onStateChanged();
  }

  // ── Exit Dialog ────────────────────────────────────────────
  Future<bool> showExitDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar Aplikasi?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  // ── Navigasi ───────────────────────────────────────────────
  void goToKamarDetail(BuildContext context, int kamarId) {
    Navigator.pushNamed(context, '/kamar-detail', arguments: {'id': kamarId});
  }

  void goToSearch(BuildContext context) {
    Navigator.pushNamed(context, '/kamar-search');
  }

  void goToKeluhan(BuildContext context) {
    Navigator.pushNamed(context, '/keluhan-list');
  }

  void goToRiwayatKos(BuildContext context) {
    Navigator.pushNamed(context, '/booking-list');
  }

  void goToSetting(BuildContext context) {
    Navigator.pushNamed(context, '/setting');
  }

  // ── Refresh (pull-to-refresh) ──────────────────────────────
  // Force ambil ulang dari API & perbarui cache
  Future<void> refresh() async {
    await loadData(forceRefresh: true);
  }
}
