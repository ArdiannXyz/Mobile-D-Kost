// ============================================================
// FRONTEND LAYER — lapor_keluhan_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'keluhan_controller.dart';

class LaporKeluhanPage extends StatefulWidget {
  const LaporKeluhanPage({super.key});

  @override
  State<LaporKeluhanPage> createState() => _LaporKeluhanPageState();
}

class _LaporKeluhanPageState extends State<LaporKeluhanPage> {
  late final KeluhanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KeluhanController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.initForm();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: switch (_controller.pageState) {
        KeluhanPageState.loading    => _buildLoadingState(),
        KeluhanPageState.noBooking  => _buildNoBookingState(),
        KeluhanPageState.hasBooking => _buildBody(),
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2ECC71),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18),
        onPressed: () => _controller.goBack(context),
      ),
      centerTitle: true,
      title: const Text(
        'Lapor Keluhan',
        style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── State: Loading ────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF2ECC71)),
          SizedBox(height: 16),
          Text(
            'Memeriksa status kamar...',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  // ── State: Tidak punya kamar aktif ───────────────────────
  Widget _buildNoBookingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.meeting_room_outlined,
                size: 48,
                color: Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Memiliki Kamar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anda perlu memiliki kamar aktif terlebih dahulu '
              'sebelum dapat melaporkan keluhan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2ECC71),
                  side: const BorderSide(color: Color(0xFF2ECC71)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── State: Punya kamar aktif → form ──────────────────────
  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Pilih Kamar'),
                const SizedBox(height: 8),
                _buildKamarDropdown(),   // ← dropdown ganti read-only field

                const SizedBox(height: 16),

                _buildLabel('Tanggal Lapor'),
                const SizedBox(height: 8),
                _buildDateField(),

                const SizedBox(height: 16),

                _buildLabel('Deskripsi Keluhan'),
                const SizedBox(height: 8),
                _buildDeskripsiField(),

                const SizedBox(height: 16),

                _buildLabel('Foto Bukti (opsional)'),
                const SizedBox(height: 8),
                _buildFotoBuktiField(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Tombol Laporkan sticky bawah
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _controller.isSubmitting
                  ? null
                  : () => _controller.laporkan(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                disabledBackgroundColor:
                    const Color(0xFF2ECC71).withOpacity(0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _controller.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Laporkan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Dropdown pilih kamar ──────────────────────────────────
  Widget _buildKamarDropdown() {
    final list = _controller.bookingAktifList;

    // Hanya satu kamar → tampil read-only seperti sebelumnya
    if (list.length == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.meeting_room_outlined,
                color: Color(0xFF9E9E9E), size: 20),
            const SizedBox(width: 10),
            Text(
              'Kamar ${list.first.nomorKamar ?? list.first.idKamar}',
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF1A1A2E)),
            ),
          ],
        ),
      );
    }

    // Lebih dari satu kamar → dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _controller.bookingAktif?.idBooking,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF9E9E9E)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          items: list.map((b) {
            return DropdownMenuItem<int>(
              value: b.idBooking,
              child: Row(
                children: [
                  const Icon(Icons.meeting_room_outlined,
                      color: Color(0xFF2ECC71), size: 18),
                  const SizedBox(width: 8),
                  Text('Kamar ${b.nomorKamar ?? b.idKamar}'),
                ],
              ),
            );
          }).toList(),
          onChanged: (idBooking) {
            if (idBooking == null) return;
            final selected = list.firstWhere((b) => b.idBooking == idBooking);
            _controller.selectBooking(selected);
          },
        ),
      ),
    );
  }

  // ── Field: Tanggal Lapor ──────────────────────────────────
  Widget _buildDateField() {
    return TextField(
      controller: _controller.tanggalController,
      readOnly: true,
      onTap: () => _controller.pickDate(context),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration().copyWith(
        suffixIcon: const Icon(Icons.calendar_month_outlined,
            color: Color(0xFF9E9E9E), size: 20),
      ),
    );
  }

  // ── Field: Deskripsi ──────────────────────────────────────
  Widget _buildDeskripsiField() {
    return TextField(
      controller: _controller.deskripsiController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration().copyWith(
        hintText: 'Jelaskan keluhan Anda... (minimal 10 karakter)',
        alignLabelWithHint: true,
      ),
    );
  }

  // ── Field: Foto Bukti ─────────────────────────────────────
  Widget _buildFotoBuktiField() {
    if (_controller.fotoBuktiBytes != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                _controller.fotoBuktiBytes!,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.image_outlined,
                      color: Color(0xFF2ECC71), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _controller.fotoBuktiNama ?? 'foto_bukti',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A1A2E)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _controller.removeFoto,
              child: const Icon(Icons.close,
                  size: 18, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _controller.pickFoto(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.attach_file_outlined,
                color: Color(0xFF9E9E9E), size: 20),
            SizedBox(width: 8),
            Text('Pilih foto bukti',
                style:
                    TextStyle(fontSize: 13, color: Color(0xFFB0B0C3))),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
      ),
    );
  }
}