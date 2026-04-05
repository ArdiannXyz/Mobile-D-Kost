// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:dkost/data/helper/api_helper.dart';
// import 'package:dkost/data/helper/api_exception.dart';
// import 'package:dkost/data/helper/api_constants.dart';
// import 'package:dkost/data/services/booking_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class TagihanUiModel {
//   final int idTagihan;
//   final int idBooking;
//   final String? namaKamar;
//   final String? fotoKamar;
//   final String periodeAwal;
//   final String periodeAkhir;
//   final String periodeBulan;
//   final double totalTagihan;
//   final double nominalDenda;
//   final String? tglJatuhTempo;
//   final String statusTagihan;

//   const TagihanUiModel({
//     required this.idTagihan,
//     required this.idBooking,
//     this.namaKamar,
//     this.fotoKamar,
//     required this.periodeAwal,
//     required this.periodeAkhir,
//     required this.periodeBulan,
//     required this.totalTagihan,
//     required this.nominalDenda,
//     this.tglJatuhTempo,
//     required this.statusTagihan,
//   });
// }

// class TagihanController {
//   bool isLoading = true;
//   bool isDeleting = false;
//   String? errorMessage;
//   List<TagihanUiModel> allTagihan = [];
//   List<TagihanUiModel> filteredTagihan = [];
//   String selectedFilter = 'Belum Bayar';
//   final VoidCallback onStateChanged;

//   TagihanController({required this.onStateChanged});

//   // Future<void> loadTagihan() async {
//   //   isLoading = true;
//   //   errorMessage = null;
//   //   onStateChanged();

//   //   try {
//   //     final userId = await ApiHelper.getUserId();
//   //     if (userId == null) {
//   //       errorMessage = 'Sesi tidak ditemukan.';
//   //       return;
//   //     }

//   //     final bookings = await BookingService.getBookingList(userId);
//   //     final List<TagihanUiModel> result = [];

//   //     for (final booking in bookings) {
//   //       if (booking.tagihan != null) {
//   //         result.add(TagihanUiModel(
//   //           idTagihan    : booking.tagihan!.idTagihan,
//   //           idBooking    : booking.idBooking,
//   //           namaKamar    : 'Kos ${_cap(booking.tipeKamar ?? '')} ${booking.nomorKamar ?? ''}',
//   //           fotoKamar    : booking.fotoKamar,
//   //           periodeAwal  : booking.tglMulaiSewa,
//   //           periodeAkhir : booking.tglAkhirSewa,
//   //           periodeBulan : booking.tglMulaiSewa,
//   //           totalTagihan : booking.tagihan!.totalTagihan,
//   //           nominalDenda : 0,
//   //           tglJatuhTempo: booking.tagihan!.tglJatuhTempo,
//   //           statusTagihan: booking.tagihan!.statusTagihan,
//   //         ));
//   //       }
//   //     }

//   //     allTagihan = result;
//   //     _applyFilter();
//   //   } on ApiException catch (e) {
//   //     errorMessage = e.message;
//   //   } catch (_) {
//   //     errorMessage = 'Gagal memuat tagihan.';
//   //   } finally {
//   //     isLoading = false;
//   //     onStateChanged();
//   //   }
//   // }

//   Future<void> loadTagihan() async {
//   isLoading = true;
//   errorMessage = null;
//   onStateChanged();

//   try {
//     final userId = await ApiHelper.getUserId();
//     if (userId == null) {
//       errorMessage = 'Sesi tidak ditemukan.';
//       return;
//     }

//     final headers = await ApiHelper.authHeaders;

//     final response = await http.get(
//       Uri.parse('${ApiConstants.baseUrl}tagihan/user/$userId'),
//       headers: headers,
//     );

//     // 🔥 DEBUG
//     print('STATUS TAGIHAN: ${response.statusCode}');
//     print('BODY TAGIHAN: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception('API ERROR ${response.statusCode}');
//     }

//     final data = jsonDecode(response.body);

//     // ✅ ambil list aman
//     final list = (data['data'] as List?) ?? [];

//     // 🔥 helper convert double (AMAN)
//     double parseDouble(dynamic val) {
//       return double.tryParse(val.toString()) ?? 0;
//     }

//     // ✅ mapping aman semua
//     allTagihan = list.map((item) {
//       return TagihanUiModel(
//         idTagihan: item['id_tagihan'] ?? 0,
//         idBooking: item['id_booking'] ?? 0,
//         namaKamar: item['nama_kamar'],
//         fotoKamar: item['foto_kamar'],
//         periodeAwal: item['tgl_mulai_sewa'] ?? '',
//         periodeAkhir: item['tgl_akhir_sewa'] ?? '',
//         periodeBulan: item['periode_bulan'] ?? '',
//         totalTagihan: parseDouble(item['total_tagihan']),   
//         nominalDenda: parseDouble(item['nominal_denda']),   
//         tglJatuhTempo: item['tgl_jatuh_tempo'],
//         statusTagihan: item['status_tagihan'] ?? '',
//       );
//     }).toList();

//     _applyFilter();
//   } catch (e) {
//     print('ERROR TAGIHAN: $e'); // 🔥 debug
//     errorMessage = 'Gagal memuat tagihan.';
//   } finally {
//     isLoading = false;
//     onStateChanged();
//   }
// }

//   // ── Hapus tagihan ──────────────────────────────────────────
//   Future<void> hapusTagihan(BuildContext context, TagihanUiModel tagihan) async {
//     // Konfirmasi dulu
//     final konfirmasi = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: const Text('Hapus Tagihan?',
//             style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//         content: const Text(
//             'Tagihan yang sudah lunas akan dihapus dari riwayat.',
//             style: TextStyle(fontSize: 13)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Batal',
//                 style: TextStyle(color: Color(0xFF9E9E9E))),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Hapus',
//                 style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (konfirmasi != true) return;

//     isDeleting = true;
//     onStateChanged();

//     try {
//       final headers = await ApiHelper.authHeaders;
//       final response = await http.delete(
//         Uri.parse('${ApiConstants.baseUrl}tagihan/${tagihan.idTagihan}'),
//         headers: headers,
//       );

//       final data = jsonDecode(response.body);
//       if (!context.mounted) return;

//       if (response.statusCode == 200 && data['success'] == true) {
//         allTagihan.removeWhere((t) => t.idTagihan == tagihan.idTagihan);
//         _applyFilter();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Tagihan berhasil dihapus.'),
//             backgroundColor: const Color(0xFF2ECC71),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       } else {
//         _showError(context, data['message'] ?? 'Gagal menghapus tagihan.');
//       }
//     } catch (e) {
//       if (context.mounted) _showError(context, 'Terjadi kesalahan: $e');
//     } finally {
//       isDeleting = false;
//       onStateChanged();
//     }
//   }

//   // ── Cek tagihan bulan ini ──────────────────────────────────
//   Future<void> cekTagihanBulanIni(
//       BuildContext context, TagihanUiModel tagihan) async {
//     try {
//       final headers = await ApiHelper.authHeaders;
//       final response = await http.get(
//         Uri.parse(
//             '${ApiConstants.baseUrl}tagihan/bulan-ini/${tagihan.idBooking}'),
//         headers: headers,
//       );

//       final data = jsonDecode(response.body);
//       if (!context.mounted) return;

//       final sudahAda = data['sudah_ada'] as bool? ?? false;
//       final bulanIni = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());

//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14)),
//           title: Text('Tagihan $bulanIni',
//               style: const TextStyle(
//                   fontSize: 15, fontWeight: FontWeight.bold)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//               sudahAda
//                   ? (data['data']?['status_tagihan'] == 'lunas'
//                       ? Icons.check_circle_outline      // ✅ lunas
//                       : Icons.cancel_outlined)          // ❌ belum bayar
//                   : Icons.pending_outlined,             // ⏳ belum dibuat
//               color: sudahAda
//                   ? (data['data']?['status_tagihan'] == 'lunas'
//                       ? const Color(0xFF2ECC71)         // hijau
//                       : const Color(0xFFE74C3C))        // merah
//                   : const Color(0xFFF39C12),            // orange
//               size: 48,
//             ),
//               const SizedBox(height: 12), 
//               Text(
//                 sudahAda
//                     ? 'Tagihan bulan ini sudah ada.\nStatus: ${_statusLabel(data['data']?['status_tagihan'] ?? '')}'
//                     : 'Tagihan bulan ini belum dibuat.',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 13, height: 1.5),
//               ),
//               if (sudahAda && data['data'] != null) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   formatHarga((data['data']['total_tagihan'] as num)
//                       .toDouble()),
//                   style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E)),
//                 ),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK',
//                   style: TextStyle(color: Color(0xFF2ECC71))),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       if (context.mounted) _showError(context, 'Gagal cek tagihan: $e');
//     }
//   }

//   void filterTagihan(String filter) {
//     selectedFilter = filter;
//     _applyFilter();
//   }

//   void _applyFilter() {
//     switch (selectedFilter) {
//       case 'Belum Bayar':
//         filteredTagihan = allTagihan
//             .where((t) => t.statusTagihan == 'belum_bayar')
//             .toList();
//         break;
//       case 'Telat':
//         filteredTagihan = allTagihan
//             .where((t) => t.statusTagihan == 'terlambat')
//             .toList();
//         break;
//       case 'Lunas':
//         filteredTagihan = allTagihan
//             .where((t) => t.statusTagihan == 'lunas')
//             .toList();
//         break;
//       default:
//         filteredTagihan = List.from(allTagihan);
//     }
//     onStateChanged();
//   }

//   String formatHarga(double harga) {
//     return NumberFormat.currency(
//             locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
//         .format(harga);
//   }

//   String formatTanggal(String tgl) {
//     try {
//       final dt = DateTime.parse(tgl);
//       return DateFormat('dd - MM - yyyy').format(dt);
//     } catch (_) {
//       return tgl;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status) {
//       case 'belum_bayar': return 'Belum Bayar';
//       case 'lunas':       return 'Lunas';
//       case 'terlambat':   return 'Telat';
//       default:            return status;
//     }
//   }

//   void showInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: const Text('Info Tagihan',
//             style:
//                 TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _InfoRow(
//                 color: Color(0xFFF39C12),
//                 label: 'Belum Bayar - tagihan aktif'),
//             SizedBox(height: 6),
//             _InfoRow(
//                 color: Color(0xFFE74C3C),
//                 label: 'Telat - melewati jatuh tempo'),
//             SizedBox(height: 6),
//             _InfoRow(
//                 color: Color(0xFF2ECC71), label: 'Lunas - sudah dibayar'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK',
//                 style: TextStyle(color: Color(0xFF2ECC71))),
//           ),
//         ],
//       ),
//     );
//   }

//   void goToDetail(BuildContext context, TagihanUiModel tagihan) {
//     Navigator.pushNamed(context, '/detail-kamarku',
//         arguments: {'booking_id': tagihan.idBooking});
//   }

//   void _showError(BuildContext context, String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: Colors.red.shade600,
//       behavior: SnackBarBehavior.floating,
//       shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   String _cap(String s) =>
//       s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
// }

// class _InfoRow extends StatelessWidget {
//   final Color color;
//   final String label;
//   const _InfoRow({required this.color, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//             width: 12,
//             height: 12,
//             decoration:
//                 BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 8),
//         Text(label, style: const TextStyle(fontSize: 13)),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:dkost/data/helper/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TagihanUiModel {
  final int idTagihan;
  final int idBooking;
  final String? namaKamar;
  final String? fotoKamar;
  final String periodeAwal;
  final String periodeAkhir;
  final String periodeBulan;
  final double totalTagihan;
  final double nominalDenda;
  final String? tglJatuhTempo;
  final String statusTagihan;
  final String statusBooking;
  final String tglBooking;

  const TagihanUiModel({
    required this.idTagihan,
    required this.idBooking,
    this.namaKamar,
    this.fotoKamar,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.periodeBulan,
    required this.totalTagihan,
    required this.nominalDenda,
    this.tglJatuhTempo,
    required this.statusTagihan,
    required this.statusBooking,
    required this.tglBooking,
  });
}

class TagihanController {
  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  List<TagihanUiModel> allTagihan = [];
  List<TagihanUiModel> filteredTagihan = [];

  String selectedFilter = 'Belum Bayar';
  final VoidCallback onStateChanged;

  TagihanController({required this.onStateChanged});

  // ── LOAD TAGIHAN ─────────────────────────
  Future<void> loadTagihan() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged();

    try {
      final userId = await ApiHelper.getUserId();

      if (userId == null) {
        errorMessage = 'Sesi tidak ditemukan';
        isLoading = false;
        onStateChanged();
        return;
      }

      final headers = await ApiHelper.authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}tagihan/user/$userId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        errorMessage = data['message'] ?? 'Gagal memuat tagihan.';
        return;
      }

      final List list = data['data'] ?? [];

      allTagihan = list.map((e) {
        double parseDouble(dynamic v) =>
            v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

        return TagihanUiModel(
          idTagihan: e['id_tagihan'] as int,
          idBooking: e['id_booking'] as int,
          namaKamar: e['nama_kamar'] as String?,
          fotoKamar: e['foto_kamar'] as String?,
          periodeAwal: e['tgl_mulai_sewa'] as String? ?? '',
          periodeAkhir: e['tgl_akhir_sewa'] as String? ?? '',
          periodeBulan: e['periode_bulan'] as String? ?? '',
          totalTagihan: parseDouble(e['total_tagihan']),
          nominalDenda: parseDouble(e['nominal_denda']),
          tglJatuhTempo: e['tgl_jatuh_tempo'] as String?,
          statusTagihan: e['status_tagihan'] as String,
          statusBooking: e['status_booking'] as String? ?? 'aktif',
          tglBooking: e['periode_bulan'] as String? ?? '',
        );
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage = 'Gagal memuat tagihan';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // ── HAPUS TAGIHAN ────────────────────────
  Future<void> hapusTagihan(
      BuildContext context, TagihanUiModel tagihan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Tagihan?'),
        content: const Text(
            'Tagihan yang sudah lunas akan dihapus dari riwayat.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (konfirmasi != true) return;

    isDeleting = true;
    onStateChanged();

    try {
      final headers = await ApiHelper.authHeaders;
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}tagihan/${tagihan.idTagihan}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception();
      }

      final List list = data['data'] ?? [];

      allTagihan = list.map((e) {
        double parseDouble(dynamic v) =>
            v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

        return TagihanUiModel(
          idTagihan: e['id_tagihan'] as int,
          idBooking: e['id_booking'] as int,
          namaKamar: e['nama_kamar'] as String?,
          fotoKamar: e['foto_kamar'] as String?,
          periodeAwal: e['tgl_mulai_sewa'] as String? ?? '',
          periodeAkhir: e['tgl_akhir_sewa'] as String? ?? '',
          periodeBulan: e['periode_bulan'] as String? ?? '',
          totalTagihan: parseDouble(e['total_tagihan']),
          nominalDenda: parseDouble(e['nominal_denda']),
          tglJatuhTempo: e['tgl_jatuh_tempo'] as String?,
          statusTagihan: e['status_tagihan'] as String,
          statusBooking: e['status_booking'] as String? ?? 'aktif',
          tglBooking: e['periode_bulan'] as String? ?? '',
        );
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage = 'Gagal hapus tagihan';
    } finally {
      isDeleting = false;
      onStateChanged();
    }
  }

  // ── FILTER ───────────────────────────────
  void filterTagihan(String filter) {
    selectedFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (selectedFilter) {
      case 'Belum Bayar':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking != 'batal' &&
                t.statusTagihan == 'belum_bayar')
            .toList();
        break;
      case 'Lunas':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking != 'batal' &&
                t.statusTagihan == 'lunas')
            .toList();
        break;
      case 'Batal':
        filteredTagihan =
            allTagihan.where((t) => t.statusBooking == 'batal').toList();
        break;
      default:
        filteredTagihan = List.from(allTagihan);
    }

    onStateChanged();
  }

  // ── FORMAT ───────────────────────────────
  String formatHarga(double harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  String formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  // ── INFO ─────────────────────────────────
  void showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info Tagihan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Belum Bayar = tagihan aktif'),
            Text('• Lunas = sudah dibayar'),
            Text('• Batal = booking dibatalkan'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  // ── GO TO DETAIL ─────────────────────────
  void goToDetail(BuildContext context, TagihanUiModel tagihan) {
    Navigator.pushNamed(context, '/detail-kamarku',
        arguments: {'booking_id': tagihan.idBooking});
  }

  // ── ERROR ────────────────────────────────
  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}