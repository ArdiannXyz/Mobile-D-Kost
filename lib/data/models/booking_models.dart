// ============================================================
// BACKEND LAYER — booking_model.dart
// Model sesuai ERD tabel `booking` + `booking_detail_furnitur`
// ============================================================

class BookingModel {
  final int idBooking;
  final int idUser;
  final int idKamar;
  final String tglBooking;
  final int durasiSewaBulan;
  final String tglMulaiSewa;
  final String tglAkhirSewa;
  final double totalBiayaBulanan;
  final String statusBooking;
  final DateTime? expiredAt; // ← diubah dari String? ke DateTime?

  // Join dari tabel kamar
  final String? nomorKamar;
  final String? tipeKamar;
  final String? fotoKamar;

  // Furnitur tambahan
  final List<BookingFurniturItem> furniturList;

  // Tagihan terkait
  final TagihanSummary? tagihan;

  const BookingModel({
    required this.idBooking,
    required this.idUser,
    required this.idKamar,
    required this.tglBooking,
    required this.durasiSewaBulan,
    required this.tglMulaiSewa,
    required this.tglAkhirSewa,
    required this.totalBiayaBulanan,
    required this.statusBooking,
    this.expiredAt,
    this.nomorKamar,
    this.tipeKamar,
    this.fotoKamar,
    this.furniturList = const [],
    this.tagihan,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      idBooking         : json['id_booking'],
      idUser            : json['id_user'],
      idKamar           : json['id_kamar'],
      tglBooking        : json['tgl_booking'] ?? '',
      durasiSewaBulan   : json['durasi_sewa_bulan'] ?? 1,
      tglMulaiSewa      : json['tgl_mulai_sewa'] ?? '',
      tglAkhirSewa      : json['tgl_akhir_sewa'] ?? '',
      totalBiayaBulanan : double.tryParse(
                            json['total_biaya_bulanan'].toString()) ?? 0,
      statusBooking     : json['status_booking'] ?? 'menunggu_pembayaran',
      // ── expired_at: parse string ISO 8601 → DateTime (UTC-aware) ──
      expiredAt         : json['expired_at'] != null
                            ? DateTime.tryParse(json['expired_at'])?.toLocal()
                            : null,
      nomorKamar        : json['nomor_kamar'],
      tipeKamar         : json['tipe_kamar'],
      fotoKamar         : json['foto_primary'] ?? json['foto_kamar'],
      furniturList      : (json['furnitur'] as List? ?? [])
                            .map((e) => BookingFurniturItem.fromJson(e))
                            .toList(),
      tagihan           : json['tagihan'] != null
                            ? TagihanSummary.fromJson(json['tagihan'])
                            : null,
    );
  }
  factory BookingModel.fromJsonAktif(Map<String, dynamic> json) {
    return BookingModel(
      idBooking         : json['id_booking'],
      idUser            : json['id_user'] ?? 0,
      idKamar           : json['id_kamar'],
      tglBooking        : json['tgl_booking'] ?? '',
      durasiSewaBulan   : json['durasi_sewa_bulan'] ?? 0,
      tglMulaiSewa      : json['tgl_mulai_sewa'] ?? '',
      tglAkhirSewa      : json['tgl_akhir_sewa'] ?? '',
      totalBiayaBulanan : double.tryParse(
                            json['total_biaya_bulanan']?.toString() ?? '0') ?? 0,
      statusBooking     : json['status_booking'] ?? 'aktif',
      expiredAt         : json['expired_at'] != null
                            ? DateTime.tryParse(json['expired_at'])?.toLocal()
                            : null,
      nomorKamar        : json['nomor_kamar'],
      tipeKamar         : json['tipe_kamar'],
      furniturList      : [],
      tagihan           : null,
    );
  }
  // ── Helper: apakah booking sudah expired ──────────────────
  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt!);
  }

  // ── Helper: sisa waktu hingga expired ─────────────────────
  Duration get timeUntilExpired {
    if (expiredAt == null) return Duration.zero;
    final remaining = expiredAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

// ============================================================
// BookingFurniturItem
// ============================================================
class BookingFurniturItem {
  final int idFurnitur;
  final String namaFurnitur;
  final int jumlah;
  final double hargaSewaTambahan;

  const BookingFurniturItem({
    required this.idFurnitur,
    required this.namaFurnitur,
    required this.jumlah,
    required this.hargaSewaTambahan,
  });

  factory BookingFurniturItem.fromJson(Map<String, dynamic> json) {
    return BookingFurniturItem(
      idFurnitur        : json['id_furnitur'],
      namaFurnitur      : json['nama_furnitur'] ?? '',
      jumlah            : json['jumlah'] ?? 1,
      hargaSewaTambahan : double.tryParse(
                            json['harga_sewa_tambahan'].toString()) ?? 0,
    );
  }

  // ── Subtotal untuk 1 item (tanpa durasi, durasi dihitung di controller) ──
  double get subtotal => hargaSewaTambahan * jumlah;
}

// ============================================================
// TagihanSummary
// ============================================================
class TagihanSummary {
  final int idTagihan;
  final double totalTagihan;
  final String statusTagihan;
  final String tglJatuhTempo;

  const TagihanSummary({
    required this.idTagihan,
    required this.totalTagihan,
    required this.statusTagihan,
    required this.tglJatuhTempo,
  });

  factory TagihanSummary.fromJson(Map<String, dynamic> json) {
    return TagihanSummary(
      idTagihan     : json['id_tagihan'],
      totalTagihan  : double.tryParse(json['total_tagihan'].toString()) ?? 0,
      statusTagihan : json['status_tagihan'] ?? 'belum_bayar',
      tglJatuhTempo : json['tgl_jatuh_tempo'] ?? '',
    );
  }

  // ── Helper: apakah tagihan sudah lewat jatuh tempo ────────
  bool get isOverdue {
    try {
      final jatuhTempo = DateTime.parse(tglJatuhTempo);
      return DateTime.now().isAfter(jatuhTempo) && statusTagihan == 'belum_bayar';
    } catch (_) {
      return false;
    }
  }
}