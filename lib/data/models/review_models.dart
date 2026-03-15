// ============================================================
// BACKEND LAYER — review_model.dart
// Model sesuai ERD tabel `review`
// ============================================================

class ReviewModel {
  final int idReview;
  final int idUser;
  final int idKamar;
  final int rating;
  final String komentar;
  final String tglReview;
  final String namaUser; // join dari tabel users

  const ReviewModel({
    required this.idReview,
    required this.idUser,
    required this.idKamar,
    required this.rating,
    required this.komentar,
    required this.tglReview,
    required this.namaUser,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      idReview: json['id_review'],
      idUser: json['id_user'],
      idKamar: json['id_kamar'],
      rating: json['rating'] ?? 0,
      komentar: json['komentar'] ?? '',
      tglReview: json['tgl_review'] ?? '',
      namaUser: json['nama'] ?? json['nama_user'] ?? 'Pengguna',
    );
  }
}