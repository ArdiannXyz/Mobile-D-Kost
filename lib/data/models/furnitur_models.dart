// ============================================================
// BACKEND LAYER — furnitur_model.dart
// Model sesuai ERD tabel `furnitur`
// ============================================================

class FurniturModel {
  final int idFurnitur;
  final String namaFurnitur;
  final int jumlah;
  final double hargaSewaTambahan;

  const FurniturModel({
    required this.idFurnitur,
    required this.namaFurnitur,
    required this.jumlah,
    required this.hargaSewaTambahan,
  });

  factory FurniturModel.fromJson(Map<String, dynamic> json) {
    return FurniturModel(
      idFurnitur: json['id_furnitur'],
      namaFurnitur: json['nama_furnitur'],
      jumlah: json['jumlah'] ?? 0,
      hargaSewaTambahan: double.tryParse(
              json['harga_sewa_tambahan'].toString()) ??
          0,
    );
  }
}