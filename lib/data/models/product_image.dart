import '../../Core/utils/parsing_utils.dart';

class ProductImage {
  final int idFoto;
  final int idKamar;
  final String urlFoto;  // URL lengkap dari Laravel
  final bool isMain;

  ProductImage({
    required this.idFoto,
    required this.idKamar,
    required this.urlFoto,
    required this.isMain,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      idFoto:   json['id_foto'],
      idKamar:  json['id_kamar'],
      urlFoto:  json['url_foto'] ?? '',  // URL langsung dari API
      isMain:   json['is_main'].toString() == '1' || json['is_main'] == true,
    );
  }
}
