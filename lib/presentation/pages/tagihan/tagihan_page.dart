import 'package:dkost/data/helper/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dkost/data/helper/api_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dkost/main.dart';

// ============================================================
// MODEL
// ============================================================
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

// ============================================================
// CONTROLLER
// ============================================================
class TagihanController {
  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  List<TagihanUiModel> allTagihan = [];
  List<TagihanUiModel> filteredTagihan = [];

  String selectedFilter = 'Belum Bayar';
  final VoidCallback onStateChanged;

  TagihanController({required this.onStateChanged});

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
        isLoading = false;
        onStateChanged();
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
      errorMessage = 'Gagal memuat tagihan: ${e.toString()}';
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

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
                t.statusBooking != 'selesai' &&
                t.statusBooking != 'expired' &&
                t.statusTagihan == 'belum_bayar')
            .toList();
        break;

      case 'Lunas':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking != 'batal' &&
                t.statusBooking != 'selesai' &&
                t.statusBooking != 'expired' &&
                t.statusTagihan == 'lunas')
            .toList();
        break;

      case 'Batal':
        filteredTagihan = allTagihan
            .where((t) =>
                t.statusBooking == 'batal' || t.statusBooking == 'expired')
            .toList();
        break;

      case 'Selesai':
        filteredTagihan =
            allTagihan.where((t) => t.statusBooking == 'selesai').toList();
        break;

      default:
        filteredTagihan = List.from(allTagihan);
    }
    onStateChanged();
  }

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
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  void showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Info Tagihan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 🟡 Belum Bayar = tagihan aktif menunggu pembayaran'),
            Text('• 🟢 Lunas = sudah dibayar lunas'),
            Text('• ⚫ Batal = booking dibatalkan'),
            Text('• 🔴 Kadaluarsa = waktu pembayaran habis'),
            Text('• 🔵 Selesai = masa sewa telah selesai'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1BBA8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child:
                const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void goToDetail(BuildContext context, TagihanUiModel tagihan) {
    Navigator.pushNamed(
      context,
      '/detail-kamarku',
      arguments: {'booking_id': tagihan.idBooking},
    ).then((result) {
      if (result == 'selesai' || result == 'refresh') {
        loadTagihan();
      }
    });
  }
}

// ============================================================
// PAGE
// ============================================================
class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => TagihanPageState();
}

// State dibuat public agar bisa diakses melalui GlobalKey dari home_page
class TagihanPageState extends State<TagihanPage> with RouteAware {
  late final TagihanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TagihanController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.loadTagihan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe cast: hanya subscribe jika ini memang PageRoute
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _controller.loadTagihan();
  }

  // Method publik untuk dipanggil dari GlobalKey (home_page)
  void refreshData() {
    _controller.loadTagihan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1BBA8A),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
      ),
      child: const Center(
        child: Text(
          'Tagihan Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Belum Bayar', 'color': Color(0xFFF39C12)},
      {'label': 'Lunas', 'color': Color(0xFF1BBA8A)},
      {'label': 'Batal', 'color': Color(0xFF9E9E9E)},
      {'label': 'Selesai', 'color': Color(0xFF3498DB)},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ...filters.map((filter) {
            final label = filter['label'] as String;
            final color = filter['color'] as Color;
            final isSelected = _controller.selectedFilter == label;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _controller.filterTagihan(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF555555),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => _controller.showInfo(context),
            child: const Icon(Icons.info_outline,
                color: Color(0xFF9E9E9E), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1BBA8A)),
      );
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: Color(0xFFB0B0C3)),
              const SizedBox(height: 12),
              Text(_controller.errorMessage!,
                  style: const TextStyle(color: Color(0xFF9E9E9E))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadTagihan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBA8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.filteredTagihan.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: Color(0xFFB0B0C3)),
            const SizedBox(height: 14),
            Text(
              'Tidak ada tagihan ${_controller.selectedFilter.toLowerCase()}',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.loadTagihan(),
      color: const Color(0xFF1BBA8A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.filteredTagihan.length,
        itemBuilder: (context, index) {
          final tagihan = _controller.filteredTagihan[index];
          return _TagihanCard(
            tagihan: tagihan,
            controller: _controller,
          );
        },
      ),
    );
  }
}

// ============================================================
// TAGIHAN CARD
// ============================================================
class _TagihanCard extends StatelessWidget {
  final TagihanUiModel tagihan;
  final TagihanController controller;

  const _TagihanCard({
    required this.tagihan,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isBatal = tagihan.statusBooking == 'batal';
    final isExpired = tagihan.statusBooking == 'expired';
    final isSelesai = tagihan.statusBooking == 'selesai';
    final isLunas = tagihan.statusTagihan == 'lunas';
    final isBelumBayar = tagihan.statusTagihan == 'belum_bayar' &&
        !isBatal &&
        !isExpired &&
        !isSelesai;

    return GestureDetector(
      onTap: () => controller.goToDetail(context, tagihan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Banner berdasarkan status
            if (isBatal)
              _buildBanner(
                color: const Color(0xFF9E9E9E),
                icon: Icons.cancel_outlined,
                text: 'Booking telah dibatalkan',
              ),
            if (isExpired)
              _buildBanner(
                color: const Color(0xFFE74C3C),
                icon: Icons.timer_off_outlined,
                text: 'Waktu pembayaran telah kadaluarsa',
              ),
            if (isSelesai)
              _buildBanner(
                color: const Color(0xFF3498DB),
                icon: Icons.check_circle_outline,
                text: 'Masa sewa telah selesai',
              ),
            if (isLunas && !isBatal && !isExpired && !isSelesai)
              _buildBanner(
                color: const Color(0xFF1BBA8A),
                icon: Icons.check_circle_outline,
                text: 'Tagihan telah lunas',
              ),
            if (isBelumBayar)
              _buildBanner(
                color: const Color(0xFFF39C12),
                icon: Icons.access_time_outlined,
                text: 'Menunggu pembayaran',
              ),

            // Konten kartu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildImage(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfo(),
                  ),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: tagihan.fotoKamar != null
          ? Image.network(
              '${ApiConstants.storageUrl}${tagihan.fotoKamar!}',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.bed_outlined, color: Color(0xFF1BBA8A), size: 28),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tagihan.namaKamar ?? 'Kamar',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sewa: ${controller.formatTanggal(tagihan.periodeAwal)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
        Text(
          'Berakhir: ${controller.formatTanggal(tagihan.periodeAkhir)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
        const SizedBox(height: 6),
        Text(
          controller.formatHarga(tagihan.totalTagihan),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isBatal = tagihan.statusBooking == 'batal';
    final isExpired = tagihan.statusBooking == 'expired';
    final isSelesai = tagihan.statusBooking == 'selesai';

    if (isBatal) {
      return _badge(const Color(0xFF9E9E9E), 'Batal');
    }
    if (isExpired) {
      return _badge(const Color(0xFFE74C3C), 'Kadaluarsa');
    }
    if (isSelesai) {
      return _badge(const Color(0xFF3498DB), 'Selesai');
    }
    if (tagihan.statusTagihan == 'lunas') {
      return _badge(const Color(0xFF1BBA8A), 'Lunas');
    }
    if (tagihan.statusTagihan == 'terlambat') {
      return _badge(const Color(0xFFE74C3C), 'Terlambat');
    }
    return _badge(const Color(0xFFF39C12), 'Belum Bayar');
  }

  Widget _badge(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
