import 'package:dkost/data/helper/api_constants.dart';
import 'package:flutter/material.dart';
import 'tagihan_controller.dart';
import 'package:dkost/data/models/tagihan_models.dart';
import 'package:dkost/main.dart';


    class TagihanPage extends StatefulWidget {
      const TagihanPage({super.key});

      @override
      State<TagihanPage> createState() => _TagihanPageState();
    }
    // ← with WidgetsBindingObserver dihapus — penyebab reload loop
    class _TagihanPageState extends State<TagihanPage> with RouteAware {
      late final TagihanController _controller;

      @override
      void initState() {
        super.initState();
        _controller = TagihanController(
          onStateChanged: () { if (mounted) setState(() {}); },
        );
        _controller.loadTagihan();
      }

      @override
      void didChangeDependencies() {
        super.didChangeDependencies();
        routeObserver.subscribe(this, ModalRoute.of(context)!);
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
            top   : MediaQuery.of(context).padding.top + 12,
            bottom: 16,
          ),
          child: const Center(
            child: Text(
              'Tagihan',
              style: TextStyle(
                color     : Colors.white,
                fontSize  : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

Widget _buildFilterChips() {
  const filters = ['Belum Bayar', 'Batal', 'Lunas', 'Selesai']; // ← tambah
  return Container(
    color  : Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        ...filters.map((f) {
          final isSelected = _controller.selectedFilter == f;

          Color activeColor;
          switch (f) {
            case 'Batal':
              activeColor = const Color(0xFF9E9E9E);
              break;
            case 'Lunas':
              activeColor = const Color(0xFF1BBA8A);
              break;
            case 'Selesai':                        // ← tambah
              activeColor = const Color(0xFF3498DB);
              break;
            default:
              activeColor = const Color(0xFFF39C12);
          }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _controller.filterTagihan(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? activeColor : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize  : 12,
                          fontWeight: FontWeight.w500,
                          color     : isSelected ? Colors.white : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              GestureDetector(
                onTap : () => _controller.showInfo(context),
                child : const Icon(Icons.info_outline,
                    color: Color(0xFF9E9E9E), size: 20),
              ),
            ],
          ),
        );
      }

      Widget _buildContent() {
        if (_controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1BBA8A)));
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

        return ListView.builder(
          padding    : const EdgeInsets.all(16),
          itemCount  : _controller.filteredTagihan.length,
          itemBuilder: (context, index) {
            final tagihan = _controller.filteredTagihan[index];
            return _TagihanCard(
              tagihan   : tagihan,
              controller: _controller,
              onTap     : () => _controller.goToDetail(context, tagihan),
            );
          },
        );
      }
    }

    // ── Tagihan Card ───────────────────────────────────────────────
    class _TagihanCard extends StatelessWidget {
      final TagihanUiModel tagihan;
      final TagihanController controller;
      final VoidCallback onTap;

      const _TagihanCard({
        required this.tagihan,
        required this.controller,
        required this.onTap,
      });

      @override
      Widget build(BuildContext context) {
        final isBatal   = tagihan.statusBooking == 'batal';
        final isSelesai = tagihan.statusBooking == 'selesai';

        return GestureDetector(
          onTap: onTap,  // semua bisa diklik
          child: Container(
            margin    : const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color       : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow   : const [
                BoxShadow(
                    color    : Color(0x0A000000),
                    blurRadius: 6,
                    offset   : Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // ── Banner Batal ──────────────────────────────
                if (isBatal)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.only(
                        topLeft : Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 14, color: Color(0xFF9E9E9E)),
                        SizedBox(width: 6),
                        Text('Booking ini telah dibatalkan',
                            style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),

                // ── Banner Selesai ────────────────────────────
                if (isSelesai)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(
                        topLeft : Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF3498DB)),
                        SizedBox(width: 6),
                        Text('Sewa telah selesai',
                            style: TextStyle(fontSize: 11, color: Color(0xFF3498DB))),
                      ],
                    ),
                  ),

                // ── Banner Lunas ──────────────────────────────
                if (!isBatal && !isSelesai && tagihan.statusTagihan == 'lunas')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.only(
                        topLeft : Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF1BBA8A)),
                        SizedBox(width: 6),
                        Text('Tagihan telah lunas',
                            style: TextStyle(fontSize: 11, color: Color(0xFF1BBA8A))),
                      ],
                    ),
                  ),

                // ── Banner Belum Bayar ────────────────────────
                if (!isBatal && !isSelesai && tagihan.statusTagihan == 'belum_bayar')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.only(
                        topLeft : Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 14, color: Color(0xFFF39C12)),
                        SizedBox(width: 6),
                        Text('Menunggu pembayaran',
                            style: TextStyle(fontSize: 11, color: Color(0xFFF39C12))),
                      ],
                    ),
                  ),

                // ── Konten Kartu ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: tagihan.fotoKamar != null
                            ? Image.network(
                                '${ApiConstants.storageUrl}${tagihan.fotoKamar!}',
                                width       : 72,
                                height      : 72,
                                fit         : BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tagihan.namaKamar ?? 'Kamar',
                              style: const TextStyle(
                                fontSize  : 14,
                                fontWeight: FontWeight.bold,
                                color     : Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sewa : ${controller.formatTanggal(tagihan.periodeAwal)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                            ),
                            Text(
                              'Berakhir : ${controller.formatTanggal(tagihan.periodeAkhir)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.formatHarga(tagihan.totalTagihan),
                              style: const TextStyle(
                                fontSize  : 14,
                                fontWeight: FontWeight.bold,
                                color     : Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(
                        statusTagihan: tagihan.statusTagihan,
                        statusBooking: tagihan.statusBooking,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
      }

      Widget _placeholder() {
        return Container(
          width : 72,
          height: 72,
          decoration: BoxDecoration(
            color       : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bed_outlined,
              color: Color(0xFF1BBA8A), size: 28),
        );
      }
    }

    // ── Status Badge ───────────────────────────────────────────────
    class _StatusBadge extends StatelessWidget {
      final String statusTagihan;
      final String statusBooking;

      const _StatusBadge({
        required this.statusTagihan,
        required this.statusBooking,
      });

      Widget build(BuildContext context) {
        if (statusBooking == 'batal') {
          return _badge(const Color(0xFF9E9E9E), 'Batal');
        }
        if (statusBooking == 'selesai') {              // ← tambah ini
          return _badge(const Color(0xFF3498DB), 'Selesai');
        }
        switch (statusTagihan) {
          case 'lunas':
            return _badge(const Color(0xFF1BBA8A), 'Lunas');
          case 'terlambat':
            return _badge(const Color(0xFFE74C3C), 'Telat');
          default:
            return _badge(const Color(0xFFF39C12), 'Belum Bayar');
        }
      }

      Widget _badge(Color color, String label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color       : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border      : Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize  : 10,
              fontWeight: FontWeight.w600,
              color     : color,
            ),
          ),
        );
      }
    }
