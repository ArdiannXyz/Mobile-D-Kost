// ============================================================
// WIDGET PREVIEW FOTO — foto_bukti_preview.dart
// Kompatibel Flutter Web & Mobile
// Letakkan di dalam lapor_keluhan_page.dart pada bagian
// widget foto bukti, atau sebagai widget terpisah.
// ============================================================

// ── Cara pakai di lapor_keluhan_page.dart ─────────────────
// Ganti semua penggunaan Image.file(controller.fotoBukti!)
// dengan widget ini:
//
//   _FotoBuktiPreview(
//     bytes   : _controller.fotoBuktiBytes,
//     nama    : _controller.fotoBuktiNama,
//     onPick  : () => _controller.pickFoto(context),
//     onRemove: () => _controller.removeFoto(),
//   )
// ══════════════════════════════════════════════════════════

import 'dart:typed_data';
import 'package:flutter/material.dart';

class FotoBuktiPreview extends StatelessWidget {
  final Uint8List? bytes;
  final String? nama;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const FotoBuktiPreview({
    super.key,
    required this.bytes,
    required this.nama,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes == null) {
      // Belum ada foto — tampilkan tombol pilih
      return GestureDetector(
        onTap: onPick,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF2ECC71), size: 32),
              SizedBox(height: 8),
              Text(
                'Tambah Foto Bukti',
                style:
                    TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'Opsional',
                style:
                    TextStyle(color: Color(0xFFB0B0C3), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    // Sudah ada foto — tampilkan preview dengan tombol hapus
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(        // ← Image.memory, bukan Image.file
            bytes!,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 160,
              color: const Color(0xFFE8F5E9),
              child: const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: Color(0xFF2ECC71), size: 40),
              ),
            ),
          ),
        ),

        // Tombol hapus (X) pojok kanan atas
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  color: Colors.white, size: 16),
            ),
          ),
        ),

        // Nama file di bawah
        if (nama != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10)),
                color: Colors.black.withOpacity(0.45),
              ),
              child: Text(
                nama!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis),
                maxLines: 1,
              ),
            ),
          ),
      ],
    );
  }
}