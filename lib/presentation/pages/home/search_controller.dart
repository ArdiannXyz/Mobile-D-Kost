// ============================================================
// BACKEND LAYER — search_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/kamar_models.dart';

enum SearchMode { suggestion, results }

class SearchController {
  bool isLoading = true;
  SearchMode currentMode = SearchMode.suggestion;
  String currentQuery = '';

  List<KamarModel> allKamar = [];
  List<KamarModel> searchResults = [];
  List<String> searchHistory = [];
  List<String> searchSuggestions = [];

  static const List<String> popularKeywords = [
    'Kos Biasa',
    'Kos Sedang',
    'Kos Mewah',
    'Kamar Tersedia',
    'Harga Terjangkau',
  ];

  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final VoidCallback onStateChanged;

  SearchController({required this.onStateChanged});

  Future<void> init() async {
    isLoading = true;
    onStateChanged();
    try {
      await Future.wait([_loadKamar(), _loadSearchHistory()]);
    } catch (_) {}
    finally {
      isLoading = false;
      onStateChanged();
    }
    searchTextController.addListener(_onTextChanged);
  }

  void dispose() {
    searchTextController.removeListener(_onTextChanged);
    searchTextController.dispose();
    searchFocusNode.dispose();
  }

  Future<void> _loadKamar() async {
    try {
      allKamar = await KamarService.getKamarList();
    } on ApiException { rethrow; } catch (_) {}
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory = prefs.getStringList('kamar_search_history') ?? [];
  }

  Future<void> _saveToHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    searchHistory.remove(query);
    searchHistory.insert(0, query);
    if (searchHistory.length > 10) searchHistory = searchHistory.sublist(0, 10);
    await prefs.setStringList('kamar_search_history', searchHistory);
  }

  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.remove(query);
    await prefs.setStringList('kamar_search_history', searchHistory);
    onStateChanged();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.clear();
    await prefs.setStringList('kamar_search_history', []);
    onStateChanged();
  }

  void _onTextChanged() {
    final query = searchTextController.text.trim();
    if (query.isEmpty) {
      searchSuggestions = [];
      currentMode = SearchMode.suggestion;
      onStateChanged();
      return;
    }

    final suggestions = allKamar
        .where((k) {
          final namaLengkap = 'kos ${k.tipeKamar} ${k.nomorKamar}'.toLowerCase();
          return namaLengkap.contains(query.toLowerCase()) ||
              k.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
              k.tipeKamar.toLowerCase().contains(query.toLowerCase());
        })
        .map((k) => 'Kos ${_cap(k.tipeKamar)} ${k.nomorKamar}')
        .toSet()
        .take(5)
        .toList();

    searchSuggestions = suggestions;
    onStateChanged();
  }

  // ── Eksekusi Pencarian ─────────────────────────────────────
  void performSearch(String query) {
    currentQuery = query.trim();
    if (currentQuery.isEmpty) return;

    _saveToHistory(currentQuery);

    final q = currentQuery.toLowerCase();

    // ── Keyword khusus harga ──────────────────────────────
    if (q.contains('terjangkau') || q.contains('murah')) {
      // Tampilkan kamar dengan harga di bawah rata-rata
      final avgHarga = allKamar.isEmpty
          ? 0.0
          : allKamar.map((k) => k.hargaPerBulan).reduce((a, b) => a + b) /
              allKamar.length;
      searchResults = allKamar
          .where((k) => k.hargaPerBulan <= avgHarga)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      currentMode = SearchMode.results;
      searchSuggestions = [];
      onStateChanged();
      return;
    }

    if (q.contains('mahal') || q.contains('premium') || q.contains('mewah')) {
      searchResults = allKamar
          .where((k) => k.tipeKamar.toLowerCase() == 'mewah')
          .toList()
        ..sort((a, b) => b.hargaPerBulan.compareTo(a.hargaPerBulan));
      currentMode = SearchMode.results;
      searchSuggestions = [];
      onStateChanged();
      return;
    }

    if (q.contains('tersedia')) {
      searchResults = allKamar
          .where((k) => k.statusKamar == 'tersedia')
          .toList();
      currentMode = SearchMode.results;
      searchSuggestions = [];
      onStateChanged();
      return;
    }

    // ── Pencarian normal berdasarkan nama/tipe/deskripsi ──
    searchResults = allKamar.where((k) {
      final namaLengkap = 'kos ${k.tipeKamar} ${k.nomorKamar}'.toLowerCase();
      return namaLengkap.contains(q) ||
          k.nomorKamar.toLowerCase().contains(q) ||
          k.tipeKamar.toLowerCase().contains(q) ||
          k.deskripsi.toLowerCase().contains(q) ||
          'kos ${k.tipeKamar}'.toLowerCase().contains(q);
    }).toList();

    currentMode = SearchMode.results;
    searchSuggestions = [];
    onStateChanged();
  }

  void useSuggestion(String suggestion) {
    searchTextController.text = suggestion;
    performSearch(suggestion);
  }

  void clearSearch() {
    searchTextController.clear();
    currentMode = SearchMode.suggestion;
    searchSuggestions = [];
    currentQuery = '';
    onStateChanged();
  }

  void goToDetail(BuildContext context, int kamarId) {
    Navigator.pushNamed(context, '/kamar-detail', arguments: {'id': kamarId});
  }

  void goBack(BuildContext context) => Navigator.pop(context);

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}