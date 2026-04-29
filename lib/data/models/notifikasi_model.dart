enum NotifikasiTipe { tagihan, keluhan, umum }

class NotifikasiItem {
  final int id;
  final String judul;
  final String pesan;
  final NotifikasiTipe tipe;
  bool sudahDibaca;
  final DateTime waktu;

  NotifikasiItem({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    required this.waktu,
  });

  factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
    return NotifikasiItem(
      id: json['id'],
      judul: json['judul'],
      pesan: json['pesan'],
      tipe: NotifikasiTipe.values.firstWhere(
        (e) => e.name == json['tipe'],
        orElse: () => NotifikasiTipe.umum,
      ),
      sudahDibaca: json['sudah_dibaca'] == true,
      waktu: DateTime.parse(json['created_at']),
    );
  }
}