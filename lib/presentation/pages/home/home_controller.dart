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
import '../../../data/models/kamar_models.dart';

class HomeController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  String? errorMessage;

  // ── Data ───────────────────────────────────────────────────
  String userName = 'Pengguna';
  List<KamarModel> semuaKamar = [];
  List<KamarModel> filteredKamar = [];
  String selectedFilter = 'Semua'; // Semua | biasa | sedang | mewah

  // Filter chips sesuai ERD tipe_kamar
  static const List<String> filterOptions = [
    'Semua',
    'Serba 300rb',   // tipe: biasa
    'Serba 600rb',   // tipe: sedang
    'Up to 900rb',   // tipe: mewah
  ];

  // Map filter label ke tipe_kamar di ERD
  static const Map<String, String?> filterToTipe = {
    'Semua': null,
    'Serba 300rb': 'biasa',
    'Serba 600rb': 'sedang',
    'Up to 900rb': 'mewah',
  };

  // Callback untuk trigger setState di View
  final VoidCallback onStateChanged;

  HomeController({required this.onStateChanged});

  // ── Load Data ──────────────────────────────────────────────
  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      // Ambil userId dari session
      final userId = await ApiHelper.getUserId();

      if (userId != null) {
        // Load nama user untuk banner
        final user = await UserService.fetchUser(userId);
        if (user != null) {
          userName = user.nama;
        }
      }

      // Load semua kamar
      final kamarList = await KamarService.getKamarList();
      semuaKamar = kamarList;
      filteredKamar = kamarList;
} catch (e) {
  errorMessage = 'Gagal memuat data. Tarik untuk refresh.';
  print('HOME ERROR: $e'); // ← tambah ini
} finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── Filter Kamar ───────────────────────────────────────────
  void applyFilter(String filterLabel) {
    selectedFilter = filterLabel;
    final tipe = filterToTipe[filterLabel];

    if (tipe == null) {
      filteredKamar = List.from(semuaKamar);
    } else {
      filteredKamar = semuaKamar
          .where((k) => k.tipeKamar == tipe)
          .toList();
    }
    onStateChanged();
  }

  // ── Search Kamar ───────────────────────────────────────────
  void searchKamar(String query) {
    if (query.isEmpty) {
      applyFilter(selectedFilter);
      return;
    }

    final tipe = filterToTipe[selectedFilter];
    filteredKamar = semuaKamar.where((k) {
      final matchQuery = k.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
          k.tipeKamar.toLowerCase().contains(query.toLowerCase());
      final matchTipe = tipe == null || k.tipeKamar == tipe;
      return matchQuery && matchTipe;
    }).toList();
    onStateChanged();
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

  // ── Refresh ────────────────────────────────────────────────
  Future<void> refresh() async {
    await loadData();
  }
}