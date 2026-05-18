class KamarModel {
  final int idKamar;
  final String nomorKamar;
  final String tipeKamar;
  final String deskripsi;
  final double hargaPerBulan;
  final String statusKamar;
  final String? fotoPrimary;
  final double? rating;
  final List<String> galeri; // ✅ TAMBAH INI

  const KamarModel({
    required this.idKamar,
    required this.nomorKamar,
    required this.tipeKamar,
    required this.deskripsi,
    required this.hargaPerBulan,
    required this.statusKamar,
    this.fotoPrimary,
    this.rating,
    this.galeri = const [], // ✅ default kosong
  });

  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      idKamar: int.tryParse(json['id_kamar'].toString()) ?? 0,
      nomorKamar: json['nomor_kamar']?.toString() ?? '',
      tipeKamar: json['tipe_kamar']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      hargaPerBulan:
          double.tryParse(json['harga_per_bulan']?.toString() ?? '0') ?? 0,
      statusKamar: json['status_kamar']?.toString() ?? 'tersedia',
      fotoPrimary: (json['foto_primary'] != null &&
              json['foto_primary'].toString().isNotEmpty)
          ? json['foto_primary'].toString()
          : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,

      // ✅ TAMBAH INI — parse list galeri
      galeri: json['galeri'] != null
          ? List<String>.from(
              (json['galeri'] as List).map((e) => e.toString()),
            )
          : [],
    );
  }

  bool get tersedia => statusKamar == 'tersedia';
}
