// ============================================================
// BACKEND LAYER — kamar_model.dart
// Model data kamar sesuai ERD tabel `kamar` dan `galeri_kamar`
// ============================================================

class KamarModel {
  final int idKamar;
  final String nomorKamar;
  final String tipeKamar;   // biasa | sedang | mewah
  final String deskripsi;
  final double hargaPerBulan;
  final String statusKamar; // tersedia | terisi | maintenance
  final String? fotoPrimary; // url dari galeri_kamar where is_main = 1
  final double? rating;     // computed dari tabel review

  const KamarModel({
    required this.idKamar,
    required this.nomorKamar,
    required this.tipeKamar,
    required this.deskripsi,
    required this.hargaPerBulan,
    required this.statusKamar,
    this.fotoPrimary,
    this.rating,
  });

  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      idKamar: json['id_kamar'],
      nomorKamar: json['nomor_kamar'],
      tipeKamar: json['tipe_kamar'],
      deskripsi: json['deskripsi'] ?? '',
      hargaPerBulan: double.tryParse(json['harga_per_bulan'].toString()) ?? 0,
      statusKamar: json['status_kamar'],
      fotoPrimary: json['foto_primary'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
    );
  }

  bool get tersedia => statusKamar == 'tersedia';
}