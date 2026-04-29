// ============================================================
// FRONTEND LAYER — kamar_card.dart
// Reusable card kamar — dipakai di:
//   - home_page: grid 2 kolom (mode: grid)
//   - home_page: horizontal scroll rekomendasi (mode: horizontal)
// Sesuai screenshot Figma: foto besar, nama, learn more + rating
// TANPA tombol "Detail Kamar" pada grid, tombol hanya di rekomendasi
// ============================================================

import 'package:flutter/material.dart';
import '../../../data/models/kamar_models.dart';

enum KamarCardMode { grid, horizontal }

class KamarCard extends StatelessWidget {
  final KamarModel kamar;
  final VoidCallback? onTap;
  final KamarCardMode mode;

  const KamarCard({
    super.key,
    required this.kamar,
    this.onTap,
    this.mode = KamarCardMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Foto Kamar ─────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: mode == KamarCardMode.horizontal ? 8 / 7 : 16 / 14,
                child: _buildImage(),
              ),
            ),

            // ── Info Kamar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nama kamar
                  Text(
                    'Kos ${_capitalize(kamar.tipeKamar)} ${kamar.nomorKamar}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // "Learn more" + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Learn more',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1BBA8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (kamar.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              kamar.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  
                  if (mode == KamarCardMode.grid) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1BBA8A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Detail Kamar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image Builder ──────────────────────────────────────────
  Widget _buildImage() {
    if (kamar.fotoPrimary != null && kamar.fotoPrimary!.isNotEmpty) {
      return Image.network(
        kamar.fotoPrimary!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _loadingImage();
        },
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(Icons.bed_outlined, color: Color(0xFF1BBA8A), size: 32),
      ),
    );
  }

  Widget _loadingImage() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: Color(0xFF1BBA8A),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
