class NotifikasiModel {
  final int id;
  final int userId;
  final String judul;
  final String pesan;
  final String tipe;
  final bool sudahDibaca;
  final String? dibacaAt;
  final String createdAt;
  final String updatedAt;

  NotifikasiModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    this.dibacaAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id          : json['id'],
      userId      : json['user_id'],
      judul       : json['judul'],
      pesan       : json['pesan'],
      tipe        : json['tipe'],
      sudahDibaca : json['sudah_dibaca'] == true || json['sudah_dibaca'] == 1,
      dibacaAt    : json['dibaca_at'],
      createdAt   : json['created_at'],
      updatedAt   : json['updated_at'],
    );
  }
}