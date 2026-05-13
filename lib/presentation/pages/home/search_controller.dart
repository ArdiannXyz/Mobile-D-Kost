// ============================================================
// BACKEND LAYER — search_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/kamar_service.dart';
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

  static const int maxHistoryLength = 4; // BATAS RIWAYAT HANYA 4

  static const List<String> popularKeywords = [
    'Kos Biasa',
    'Kos Sedang',
    'Kos Mewah',
    'Kamar Tersedia',
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
    } catch (e) {
      debugPrint('Error in init: $e');
    } finally {
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
    } catch (e) {
      debugPrint('Error loading kamar: $e');
      allKamar = [];
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      searchHistory = prefs.getStringList('kamar_search_history') ?? [];
      // Batasi hanya 4 item saat load
      if (searchHistory.length > maxHistoryLength) {
        searchHistory = searchHistory.sublist(0, maxHistoryLength);
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      searchHistory = [];
    }
  }

  Future<void> _saveToHistory(String query) async {
    if (query.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      searchHistory.remove(query);
      searchHistory.insert(0, query);
      // BATASI HANY SAMPAI 4 ITEM
      if (searchHistory.length > maxHistoryLength) {
        searchHistory = searchHistory.sublist(0, maxHistoryLength);
      }
      await prefs.setStringList('kamar_search_history', searchHistory);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  Future<void> removeFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      searchHistory.remove(query);
      await prefs.setStringList('kamar_search_history', searchHistory);
      onStateChanged();
    } catch (e) {
      debugPrint('Error removing from history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      searchHistory.clear();
      await prefs.setStringList('kamar_search_history', []);
      onStateChanged();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
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

  void performSearch(String query) {
    currentQuery = query.trim();
    if (currentQuery.isEmpty) return;
    
    _saveToHistory(currentQuery);
    final q = currentQuery.toLowerCase();

    // Pencarian berdasarkan harga dibawah 400rb
    if (q.contains('dibawah 400rb') || q.contains('dibawah 400')) {
      searchResults = allKamar
          .where((k) => k.hargaPerBulan < 400000)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      _finishSearch();
      return;
    }
    
    // Pencarian berdasarkan harga dibawah 700rb
    if (q.contains('dibawah 700rb') || q.contains('dibawah 700')) {
      searchResults = allKamar
          .where((k) => k.hargaPerBulan < 700000)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      _finishSearch();
      return;
    }
    
    // Pencarian berdasarkan harga 400rb - 700rb
    if ((q.contains('400') && q.contains('700') && q.contains('sampai')) ||
        (q.contains('400rb') && q.contains('700rb'))) {
      searchResults = allKamar
          .where((k) => k.hargaPerBulan >= 400000 && k.hargaPerBulan <= 700000)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      _finishSearch();
      return;
    }
    
    // Pencarian berdasarkan harga 700rb - 1jt
    if ((q.contains('700') && q.contains('1jt') && q.contains('sampai')) ||
        (q.contains('700rb') && q.contains('1jt'))) {
      searchResults = allKamar
          .where((k) => k.hargaPerBulan >= 700000 && k.hargaPerBulan <= 1000000)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      _finishSearch();
      return;
    }
    
    // Pencarian berdasarkan harga diatas 1jt
    if (q.contains('diatas 1jt') || q.contains('diatas 1.000.000') || q.contains('> 1jt')) {
      searchResults = allKamar
          .where((k) => k.hargaPerBulan > 1000000)
          .toList()
        ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      _finishSearch();
      return;
    }

    // Pencarian kamar termurah
    if (q.contains('termurah') || q.contains('paling murah')) {
      if (allKamar.isNotEmpty) {
        final minHarga = allKamar.map((k) => k.hargaPerBulan).reduce((a, b) => a < b ? a : b);
        searchResults = allKamar
            .where((k) => k.hargaPerBulan == minHarga)
            .toList();
      } else {
        searchResults = [];
      }
      _finishSearch();
      return;
    }
    
    // Pencarian kamar termahal
    if (q.contains('termahal') || q.contains('paling mahal')) {
      if (allKamar.isNotEmpty) {
        final maxHarga = allKamar.map((k) => k.hargaPerBulan).reduce((a, b) => a > b ? a : b);
        searchResults = allKamar
            .where((k) => k.hargaPerBulan == maxHarga)
            .toList();
      } else {
        searchResults = [];
      }
      _finishSearch();
      return;
    }

    // Keyword terjangkau/murah
    if (q.contains('terjangkau') || q.contains('murah')) {
      if (allKamar.isEmpty) {
        searchResults = [];
      } else {
        final avgHarga = allKamar.map((k) => k.hargaPerBulan).reduce((a, b) => a + b) / allKamar.length;
        searchResults = allKamar
            .where((k) => k.hargaPerBulan <= avgHarga)
            .toList()
          ..sort((a, b) => a.hargaPerBulan.compareTo(b.hargaPerBulan));
      }
      _finishSearch();
      return;
    }

    // Keyword mahal/premium/mewah
    if (q.contains('mahal') || q.contains('premium') || q.contains('mewah')) {
      searchResults = allKamar
          .where((k) => k.tipeKamar.toLowerCase() == 'mewah')
          .toList()
        ..sort((a, b) => b.hargaPerBulan.compareTo(a.hargaPerBulan));
      _finishSearch();
      return;
    }

    // Keyword tersedia
    if (q.contains('tersedia')) {
      searchResults = allKamar
          .where((k) => k.statusKamar == 'tersedia')
          .toList();
      _finishSearch();
      return;
    }

    // Pencarian normal
    searchResults = allKamar.where((k) {
      final namaLengkap = 'kos ${k.tipeKamar} ${k.nomorKamar}'.toLowerCase();
      return namaLengkap.contains(q) ||
          k.nomorKamar.toLowerCase().contains(q) ||
          k.tipeKamar.toLowerCase().contains(q) ||
          k.deskripsi.toLowerCase().contains(q) ||
          'kos ${k.tipeKamar}'.toLowerCase().contains(q);
    }).toList();
    
    _finishSearch();
  }

  void _finishSearch() {
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

  String _cap(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}