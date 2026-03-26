// class KamarModel {
//   final int idKamar;
//   final String nomorKamar;
//   final String tipeKamar;   // biasa | sedang | mewah
//   final String deskripsi;
//   final double hargaPerBulan;
//   final String statusKamar; // tersedia | terisi | maintenance
//   final String? fotoPrimary; // url dari galeri_kamar where is_main = 1
//   final double? rating;     // computed dari tabel review

//   const KamarModel({
//     required this.idKamar,
//     required this.nomorKamar,
//     required this.tipeKamar,
//     required this.deskripsi,
//     required this.hargaPerBulan,
//     required this.statusKamar,
//     this.fotoPrimary,
//     this.rating,
//   });

//   factory KamarModel.fromJson(Map<String, dynamic> json) {
//     return KamarModel(
//       idKamar: json['id_kamar'],
//       nomorKamar: json['nomor_kamar'],
//       tipeKamar: json['tipe_kamar'],
//       deskripsi: json['deskripsi'] ?? '',
//       hargaPerBulan: double.tryParse(json['harga_per_bulan'].toString()) ?? 0,
//       statusKamar: json['status_kamar'],
//       fotoPrimary: json['foto_primary'],
//       rating: json['rating'] != null
//           ? double.tryParse(json['rating'].toString())
//           : null,
//     );
//   }

//   bool get tersedia => statusKamar == 'tersedia';
// }


class KamarModel {
  final int idKamar;
  final String nomorKamar;
  final String tipeKamar;
  final String deskripsi;
  final double hargaPerBulan;
  final String statusKamar;
  final String? fotoPrimary;
  final double? rating;

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
      // ✅ AMAN dari null / string / int
      idKamar: int.tryParse(json['id_kamar'].toString()) ?? 0,

      nomorKamar: json['nomor_kamar']?.toString() ?? '',
      tipeKamar: json['tipe_kamar']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',

      // ✅ FIX DOUBLE (sering error disini)
      hargaPerBulan:
          double.tryParse(json['harga_per_bulan']?.toString() ?? '0') ?? 0,

      statusKamar: json['status_kamar']?.toString() ?? 'tersedia',

      // ✅ FIX FOTO (anti null + kosong)
      fotoPrimary: (json['foto_primary'] != null &&
              json['foto_primary'].toString().isNotEmpty)
          ? json['foto_primary'].toString()
          : null,

      // ✅ FIX RATING (kadang null)
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
    );
  }

  bool get tersedia => statusKamar == 'tersedia';
}