// ============================================================
// BACKEND LAYER — search_controller.dart
// Bertanggung jawab atas: load kamar, search real-time,
// riwayat pencarian, saran pencarian, navigasi.
//
// Yang DIHAPUS dari versi lama:
// - ProductService, UserService.fetchFavorites, toggleFavorite
// - Filter harga & rating (tidak relevan untuk kost)
// - popularKeywords batik → diganti tipe kamar D'Kost
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/kamar_service.dart';
import '../../../data/helper/api_exception.dart';
import '../../../data/models/kamar_models.dart';

enum SearchMode { suggestion, results }

class SearchController {
  // ── State ──────────────────────────────────────────────────
  bool isLoading = true;
  SearchMode currentMode = SearchMode.suggestion;
  String currentQuery = '';

  // ── Data ───────────────────────────────────────────────────
  List<KamarModel> allKamar = [];
  List<KamarModel> searchResults = [];
  List<String> searchHistory = [];
  List<String> searchSuggestions = [];

  // Kata kunci populer sesuai D'Kost
  static const List<String> popularKeywords = [
    'Kos Biasa',
    'Kos Sedang',
    'Kos Mewah',
    'Kamar Tersedia',
    'Harga Terjangkau',
  ];

  // ── Controllers ────────────────────────────────────────────
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final VoidCallback onStateChanged;

  SearchController({required this.onStateChanged});

  // ── Init ───────────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    onStateChanged();

    try {
      await Future.wait([
        _loadKamar(),
        _loadSearchHistory(),
      ]);
    } catch (_) {
      // tetap lanjut meski error
    } finally {
      isLoading = false;
      onStateChanged();
    }

    // Listen perubahan teks untuk saran
    searchTextController.addListener(_onTextChanged);
  }

  // ── Dispose ────────────────────────────────────────────────
  void dispose() {
    searchTextController.removeListener(_onTextChanged);
    searchTextController.dispose();
    searchFocusNode.dispose();
  }

  // ── Load Kamar ─────────────────────────────────────────────
  Future<void> _loadKamar() async {
    try {
      allKamar = await KamarService.getKamarList();
    } on ApiException {
      rethrow;
    } catch (_) {}
  }

  // ── Riwayat Pencarian ──────────────────────────────────────
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory = prefs.getStringList('kamar_search_history') ?? [];
  }

  Future<void> _saveToHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    searchHistory.remove(query);
    searchHistory.insert(0, query);
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(0, 10);
    }
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

  // ── Saran Real-time ────────────────────────────────────────
  void _onTextChanged() {
    final query = searchTextController.text.trim();
    if (query.isEmpty) {
      searchSuggestions = [];
      currentMode = SearchMode.suggestion;
      onStateChanged();
      return;
    }

    // Generate saran dari data kamar
    final suggestions = allKamar
        .where((k) =>
            k.nomorKamar.toLowerCase().contains(query.toLowerCase()) ||
            k.tipeKamar.toLowerCase().contains(query.toLowerCase()) ||
            k.deskripsi.toLowerCase().contains(query.toLowerCase()))
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

    searchResults = allKamar.where((k) {
      return k.nomorKamar.toLowerCase().contains(currentQuery.toLowerCase()) ||
          k.tipeKamar.toLowerCase().contains(currentQuery.toLowerCase()) ||
          k.deskripsi.toLowerCase().contains(currentQuery.toLowerCase());
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

  // ── Navigasi ───────────────────────────────────────────────
  void goToDetail(BuildContext context, int kamarId) {
    Navigator.pushNamed(context, '/kamar-detail', arguments: {'id': kamarId});
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}