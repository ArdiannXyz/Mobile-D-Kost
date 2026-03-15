// ============================================================
// BACKEND LAYER — keluhan_model.dart
// Model sesuai ERD tabel `keluhan`
// ============================================================

class KeluhanModel {
  final int idKeluhan;
  final int idUser;
  final int idKamar;
  final String deskripsiMasalah;
  final String? fotoBukti;
  final String tglLapor;
  final String statusKeluhan; // pending | diproses | selesai
  final String? nomorKamar;   // join dari tabel kamar

  const KeluhanModel({
    required this.idKeluhan,
    required this.idUser,
    required this.idKamar,
    required this.deskripsiMasalah,
    this.fotoBukti,
    required this.tglLapor,
    required this.statusKeluhan,
    this.nomorKamar,
  });

  factory KeluhanModel.fromJson(Map<String, dynamic> json) {
    return KeluhanModel(
      idKeluhan: json['id_keluhan'],
      idUser: json['id_user'],
      idKamar: json['id_kamar'],
      deskripsiMasalah: json['deskripsi_masalah'] ?? '',
      fotoBukti: json['foto_bukti'],
      tglLapor: json['tgl_lapor'] ?? '',
      statusKeluhan: json['status_keluhan'] ?? 'pending',
      nomorKamar: json['nomor_kamar'],
    );
  }
}