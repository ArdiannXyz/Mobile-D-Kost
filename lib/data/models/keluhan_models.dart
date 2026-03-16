// ============================================================
// BACKEND LAYER — keluhan_models.dart
// Model sesuai ERD tabel `keluhan`
// Fix: id_user nullable karena tidak selalu ada di response
// ============================================================

class KeluhanModel {
  final int idKeluhan;
  final int? idUser;      // ← nullable, tidak selalu ada di response
  final int idKamar;
  final String deskripsiMasalah;
  final String? fotoBukti;
  final String tglLapor;
  final String statusKeluhan;
  final String? nomorKamar;

  const KeluhanModel({
    required this.idKeluhan,
    this.idUser,
    required this.idKamar,
    required this.deskripsiMasalah,
    this.fotoBukti,
    required this.tglLapor,
    required this.statusKeluhan,
    this.nomorKamar,
  });

  factory KeluhanModel.fromJson(Map<String, dynamic> json) {
    return KeluhanModel(
      idKeluhan        : json['id_keluhan'] as int,
      idUser           : json['id_user'] as int?,       // ← nullable
      idKamar          : json['id_kamar'] as int,
      deskripsiMasalah : json['deskripsi_masalah'] ?? '',
      fotoBukti        : json['foto_bukti'],
      tglLapor         : json['tgl_lapor'] ?? '',
      statusKeluhan    : json['status_keluhan'] ?? 'pending',
      nomorKamar       : json['nomor_kamar'],
    );
  }
}