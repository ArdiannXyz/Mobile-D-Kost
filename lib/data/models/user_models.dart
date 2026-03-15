// ============================================================
// BACKEND LAYER — user_model.dart
// Model sesuai ERD tabel `users` D'Kost.
// Menambah field: alamat (ada di ERD tapi belum di model lama)
// ============================================================

class User {
  final int idUser;
  final String nama;
  final String email;
  final String noHp;
  final String? alamat;
  final String role; // admin | penyewa

  const User({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.noHp,
    this.alamat,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'] ?? json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? json['no_telepon'] ?? '',
      alamat: json['alamat'],
      role: json['role'] ?? 'penyewa',
    );
  }

  // copyWith untuk update sebagian field
  User copyWith({
    String? nama,
    String? email,
    String? noHp,
    String? alamat,
  }) {
    return User(
      idUser: idUser,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      role: role,
    );
  }
}