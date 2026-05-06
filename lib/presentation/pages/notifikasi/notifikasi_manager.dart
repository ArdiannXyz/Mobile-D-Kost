import 'package:flutter/material.dart';
import '../../../data/models/notifikasi_model.dart';
import '../../../data/services/notifikasi_api_service.dart';
import 'package:flutter/foundation.dart';

class NotifikasiManager extends ChangeNotifier {
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

  // Fetch dari API
  Future<void> muat() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _api.ambilNotifikasi();
      _items = result['items'] as List<NotifikasiItem>;
      _jumlahBelumDibaca = result['jumlah_belum_baca'] as int;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Gagal memuat notifikasi';
      debugPrint('Error muat notifikasi: $e');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Tandai 1 dibaca
  Future<void> tandaiDibaca(int id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1 && !_items[idx].sudahDibaca) {
      _items[idx].sudahDibaca = true;
      if (_jumlahBelumDibaca > 0) _jumlahBelumDibaca--;
      notifyListeners();
    }

    try {
      await _api.tandaiBaca(id);
    } catch (e) {
      debugPrint('Error tandai baca: $e');
    }
  }

  // Tandai semua dibaca
  Future<void> tandaiSemuaDibaca() async {
    for (final item in _items) {
      item.sudahDibaca = true;
    }
    _jumlahBelumDibaca = 0;
    notifyListeners();
    try {
      await _api.tandaiSemuaBaca();
    } catch (e) {
      debugPrint('Error tandai semua baca: $e');
    }
  }

  // ── Tambah notif baru (dari FCM) ── (sudah ada)
  void tambah(NotifikasiItem item) {
    _items.insert(0, item);
    if (!item.sudahDibaca) _jumlahBelumDibaca++;
    notifyListeners();
  }

  // ========== DITAMBAH: tambah notif dari push notification ==========
  void tambahDariPush(Map<String, dynamic> notificationJson) {
    try {
      // OneSignal menyimpan data di berbagai key, biasanya di 'custom' -> 'a'
      final custom = notificationJson['custom'];
      Map<String, dynamic> data = {};
      if (custom is Map) {
        data = custom['a'] ?? {};
      } else {
        data = notificationJson['data'] ?? {};
      }

      final title = notificationJson['title'] ?? 
                    notificationJson['headings']?['id'] ?? 
                    'Notifikasi';
      final body = notificationJson['body'] ?? 
                   notificationJson['contents']?['id'] ?? 
                   '';

      final notifItem = NotifikasiItem(
        id: int.tryParse(data['notifId']?.toString() ?? '0') ?? 
            DateTime.now().millisecondsSinceEpoch,
        judul: title,
        pesan: body,
        tipe: _mapTipe(data['tipe'] ?? 'umum'),
        sudahDibaca: false,
        waktu: DateTime.now(),
      );

      // Hindari duplikat (jika id sama)
      if (_items.any((item) => item.id == notifItem.id)) return;

      _items.insert(0, notifItem);
      _jumlahBelumDibaca++;
      debugPrint('Notifikasi push ditambahkan ke in-app: $title');
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing push notif: $e');
    }
  }

  NotifikasiTipe _mapTipe(String tipe) {
    switch (tipe) {
      case 'tagihan':
        return NotifikasiTipe.tagihan;
      case 'keluhan':
        return NotifikasiTipe.keluhan;
      default:
        return NotifikasiTipe.umum;
    }
  }  
}