class TagihanModel {
  final int idTagihan;
  final String namaPenyewa;
  final String nomorKamar;
  final String periodeBulan;
  final double nominalDasar;
  final double nominalDenda;
  final double totalTagihan;
  final String tglJatuhTempo;
  final String statusTagihan;

  TagihanModel({
    required this.idTagihan,
    required this.namaPenyewa,
    required this.nomorKamar,
    required this.periodeBulan,
    required this.nominalDasar,
    required this.nominalDenda,
    required this.totalTagihan,
    required this.tglJatuhTempo,
    required this.statusTagihan,
  });

  factory TagihanModel.fromJson(Map<String, dynamic> json) {
    return TagihanModel(
      idTagihan:     json['id_tagihan'],
      namaPenyewa:   json['nama_penyewa'],
      nomorKamar:    json['nomor_kamar'],
      periodeBulan:  json['periode_bulan'],
      nominalDasar:  double.parse(json['nominal_dasar'].toString()),
      nominalDenda:  double.parse(json['nominal_denda'].toString()),
      totalTagihan:  double.parse(json['total_tagihan'].toString()),
      tglJatuhTempo: json['tgl_jatuh_tempo'],
      statusTagihan: json['status_tagihan'],
    );  
  }
}