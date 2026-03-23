// ============================================================
// FRONTEND LAYER — edit_keluhan_page.dart
// UI sama seperti lapor_keluhan_page
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/models/keluhan_models.dart';
import 'keluhan_controller.dart';

class EditKeluhanPage extends StatefulWidget {
  final KeluhanModel keluhan;
  const EditKeluhanPage({super.key, required this.keluhan});

  @override
  State<EditKeluhanPage> createState() => _EditKeluhanPageState();
}

class _EditKeluhanPageState extends State<EditKeluhanPage> {
  late final KeluhanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KeluhanController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    // Pre-fill data keluhan yang ada
    _controller.initEditForm(widget.keluhan);
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
      body: _buildBody(),
    );
  }

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
        'Edit Keluhan',
        style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Nomor Kamar'),
                const SizedBox(height: 8),
                _buildReadOnlyField(_controller.nomorKamarController),

                const SizedBox(height: 16),

                _buildLabel('Tanggal Lapor'),
                const SizedBox(height: 8),
                _buildDateField(),

                const SizedBox(height: 16),

                _buildLabel('Deskripsi Keluhan'),
                const SizedBox(height: 8),
                _buildDeskripsiField(),

                const SizedBox(height: 16),

                _buildLabel('Foto Bukti'),
                const SizedBox(height: 8),
                _buildFotoBuktiField(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Tombol simpan sticky bawah
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
                  : () => _controller.editKeluhan(
                      context, widget.keluhan.idKeluhan),
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
                  : const Text('Simpan Perubahan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration().copyWith(
        fillColor: const Color(0xFFF5F5F5),
      ),
    );
  }

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

  Widget _buildDeskripsiField() {
    return TextField(
      controller: _controller.deskripsiController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration().copyWith(
        hintText: 'Jelaskan keluhan Anda...',
        alignLabelWithHint: true,
      ),
    );
  }

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

    // Tampilkan foto lama jika ada
    if (widget.keluhan.fotoBukti != null &&
        widget.keluhan.fotoBukti!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined,
                color: Color(0xFF2ECC71), size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Foto bukti sebelumnya',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
            ),
            GestureDetector(
              onTap: () => _controller.pickFoto(context),
              child: const Text('Ganti',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _controller.pickFoto(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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