// ============================================================
// CacheService — lib/data/helper/cache_service.dart
//
// Cache manager global berbasis memory (Map) dengan TTL.
// Tidak perlu package tambahan, cukup dart:core.
//
// Cara pakai:
//   // Simpan
//   CacheService.set('kamar_list', data, ttl: Duration(minutes: 5));
//
//   // Ambil (null = tidak ada / expired)
//   final cached = CacheService.get<List<KamarModel>>('kamar_list');
//
//   // Hapus satu key (misal setelah user lakukan aksi)
//   CacheService.invalidate('kamar_list');
//
//   // Hapus semua cache dengan prefix tertentu
//   CacheService.invalidatePrefix('booking_');
//
//   // Hapus semua cache (logout / refresh total)
//   CacheService.clear();
// ============================================================

class _CacheEntry<T> {
  final T data;
  final DateTime expiredAt;

  _CacheEntry({required this.data, required this.expiredAt});

  bool get isExpired => DateTime.now().isAfter(expiredAt);
}

class CacheService {
  CacheService._();

  static final Map<String, _CacheEntry<dynamic>> _store = {};

  // ── TTL default per kategori data ──────────────────────────
  static const Duration ttlKamar       = Duration(minutes: 5);
  static const Duration ttlFurnitur    = Duration(minutes: 5);
  static const Duration ttlBooking     = Duration(minutes: 2);
  static const Duration ttlUser        = Duration(minutes: 10);
  static const Duration ttlNotifikasi  = Duration(seconds: 30);
  static const Duration ttlReview      = Duration(minutes: 3);

  // ── Key constants ──────────────────────────────────────────
  static const String keyKamarList     = 'kamar_list';
  static const String keyFurniturList  = 'furnitur_list';
  static const String keyUserPrefix    = 'user_';       // + userId
  static const String keyBookingPrefix = 'booking_';    // + userId
  static const String keyBookingAktifPrefix = 'booking_aktif_'; // + userId
  static const String keyReviewPrefix  = 'review_';    // + kamarId
  static const String keyNotifPrefix   = 'notif_';     // + userId

  // ── SET: Simpan data ke cache ──────────────────────────────
  static void set<T>(String key, T data, {required Duration ttl}) {
    _store[key] = _CacheEntry<T>(
      data: data,
      expiredAt: DateTime.now().add(ttl),
    );
  }

  // ── GET: Ambil data dari cache (null jika tidak ada/expired)
  static T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null || entry.isExpired) {
      _store.remove(key); // hapus entry expired
      return null;
    }
    return entry.data as T?;
  }

  // ── INVALIDATE: Hapus satu key ─────────────────────────────
  static void invalidate(String key) {
    _store.remove(key);
  }

  // ── INVALIDATE PREFIX: Hapus semua key dengan prefix ───────
  // Contoh: invalidatePrefix('booking_') hapus semua cache booking
  static void invalidatePrefix(String prefix) {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }

  // ── CLEAR: Hapus semua cache (gunakan saat logout) ─────────
  static void clear() {
    _store.clear();
  }

  // ── DEBUG: Lihat semua key yang aktif di cache ─────────────
  static List<String> get activeKeys => _store.entries
      .where((e) => !e.value.isExpired)
      .map((e) => e.key)
      .toList();
}