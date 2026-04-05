// class TagihanModel {
//   final int idTagihan;
//   final String namaPenyewa;
//   final String nomorKamar;
//   final String periodeBulan;
//   final double nominalDasar;
//   final double nominalDenda;
//   final double totalTagihan;
//   final String tglJatuhTempo;
//   final String statusTagihan;

//   TagihanModel({
//     required this.idTagihan,
//     required this.namaPenyewa,
//     required this.nomorKamar,
//     required this.periodeBulan,
//     required this.nominalDasar,
//     required this.nominalDenda,
//     required this.totalTagihan,
//     required this.tglJatuhTempo,
//     required this.statusTagihan,
//   });

//   factory TagihanModel.fromJson(Map<String, dynamic> json) {
//     return TagihanModel(
//       idTagihan:     json['id_tagihan'],
//       namaPenyewa:   json['nama_penyewa'],
//       nomorKamar:    json['nomor_kamar'],
//       periodeBulan:  json['periode_bulan'],
//       nominalDasar:  double.parse(json['nominal_dasar'].toString()),
//       nominalDenda:  double.parse(json['nominal_denda'].toString()),
//       totalTagihan:  double.parse(json['total_tagihan'].toString()),
//       tglJatuhTempo: json['tgl_jatuh_tempo'],
//       statusTagihan: json['status_tagihan'],
//     );
//   }
// }

class TagihanModel {
  final int idTagihan;
  final int idBooking;

  final String? namaKamar;
  final String? fotoKamar;

  final String periodeAwal;
  final String periodeAkhir;
  final String periodeBulan;

  final double nominalDasar;
  final double nominalDenda;
  final double totalTagihan;

  final String tglJatuhTempo;
  final String statusTagihan;

  TagihanModel({
    required this.idTagihan,
    required this.idBooking,
    this.namaKamar,
    this.fotoKamar,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.periodeBulan,
    required this.nominalDasar,
    required this.nominalDenda,
    required this.totalTagihan,
    required this.tglJatuhTempo,
    required this.statusTagihan,
  });

  static double _parseDouble(dynamic val) {
    if (val == null) return 0;
    return double.tryParse(val.toString()) ?? 0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  factory TagihanModel.fromJson(Map<String, dynamic> json) {
    return TagihanModel(

//       idTagihan: _parseInt(json['id_tagihan']),
      idTagihan:     json['id_tagihan'],
      idBooking: _parseInt(json['id_booking']),
      namaPenyewa:   json['nama_penyewa'],
      nomorKamar:    json['nomor_kamar'],
      fotoKamar:     json['foto_kamar'],
      periodeAwal: json['tgl_mulai_sewa'] ?? '',
      periodeAkhir: json['tgl_akhir_sewa'] ?? '',
      periodeBulan:  json['periode_bulan'],
      tglJatuhTempo: json['tgl_jatuh_tempo'],
      statusTagihan: json['status_tagihan'],
      nominalDasar:  double.parse(json['nominal_dasar'].toString()),
      nominalDenda:  double.parse(json['nominal_denda'].toString()),
      totalTagihan:  double.parse(json['total_tagihan'].toString()),
      
    );  
  }
}