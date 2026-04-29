import 'package:flutter/material.dart';
import '../../../data/models/notifikasi_model.dart';
import '../../../data/services/notifikasi_api_service.dart';

class NotifikasiManager {
  static final NotifikasiManager _instance = NotifikasiManager._internal();
  factory NotifikasiManager() => _instance;
  NotifikasiManager._internal();

  final _api = NotifikasiApiService();

  List<NotifikasiItem> _items = [];
  int _jumlahBelumDibaca = 0;
  bool isLoading = false;
  String? errorMessage;

  List<NotifikasiItem> get semua => List.unmodifiable(_items);
  List<NotifikasiItem> get belumDibaca =>
      _items.where((e) => !e.sudahDibaca).toList();
  List<NotifikasiItem> get sudahDibaca =>
      _items.where((e) => e.sudahDibaca).toList();
  int get jumlahBelumDibaca => _jumlahBelumDibaca;

  // ── Fetch dari API ─────────────────────────────────────────
  Future<void> muat() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _api.ambilNotifikasi();
      _items = result['items'] as List<NotifikasiItem>;
      _jumlahBelumDibaca = result['jumlah_belum_baca'] as int;
    } catch (e) {
      errorMessage = 'Gagal memuat notifikasi';
      debugPrint('Error muat notifikasi: $e');
    } finally {
      isLoading = false;
    }
  }

  // ── Tandai 1 dibaca ────────────────────────────────────────
  Future<void> tandaiDibaca(int id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1 && !_items[idx].sudahDibaca) {
      _items[idx].sudahDibaca = true;
      if (_jumlahBelumDibaca > 0) _jumlahBelumDibaca--;
    }

    try {
      await _api.tandaiBaca(id);
    } catch (e) {
      debugPrint('Error tandai baca: $e');
    }
  }

  // ── Tandai semua dibaca ────────────────────────────────────
  Future<void> tandaiSemuaDibaca() async {
    for (final item in _items) {
      item.sudahDibaca = true;
    }
    _jumlahBelumDibaca = 0;

    try {
      await _api.tandaiSemuaBaca();
    } catch (e) {
      debugPrint('Error tandai semua baca: $e');
    }
  }

  // ── Tambah notif baru (dari FCM) ───────────────────────────
  void tambah(NotifikasiItem item) {
    _items.insert(0, item);
    if (!item.sudahDibaca) _jumlahBelumDibaca++;
  }
}