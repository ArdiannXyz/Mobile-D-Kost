<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\BookingDetailFurnitur;
use App\Models\Furnitur;
use App\Models\Kamar;
use App\Models\Tagihan;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class BookingController extends Controller
{
    // ── GET /booking/user/{userId} ──────────────────────────────
    public function indexByUser($userId)
    {
        $bookings = Booking::with(['kamar.galeri' => function ($q) {
            $q->where('is_main', 1);
        }, 'furniturDetails.furnitur', 'tagihan'])
        ->where('id_user', $userId)
        ->orderByDesc('tgl_booking')
        ->get()
        ->map(fn($b) => $this->formatBooking($b));

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // ── GET /booking/{id} ───────────────────────────────────────
    public function show($id)
    {
        $booking = Booking::with([
            'kamar.galeri' => fn($q) => $q->where('is_main', 1),
            'furniturDetails.furnitur',
            'tagihan',
        ])->find($id);

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Booking tidak ditemukan.'], 404);
        }

        return response()->json(['success' => true, 'data' => $this->formatBooking($booking)]);
    }

    // ── POST /booking ───────────────────────────────────────────
    public function store(Request $request)
    {
        $request->validate([
            'id_user'          => 'required|exists:users,id_user',
            'id_kamar'         => 'required|exists:kamar,id_kamar',
            'tgl_mulai_sewa'   => 'required|date|after_or_equal:today',
            'durasi_sewa_bulan'=> 'required|integer|min:1|max:12',
            'furnitur'         => 'nullable|array',
            'furnitur.*.id_furnitur' => 'exists:furnitur,id_furnitur',
            'furnitur.*.jumlah'      => 'integer|min:1',
        ]);

        // Cek ketersediaan kamar
        $kamar = Kamar::find($request->id_kamar);
        if ($kamar->status_kamar !== 'tersedia') {
            return response()->json([
                'success' => false,
                'message' => 'Kamar sudah tidak tersedia.',
            ], 422);
        }

        // Hitung total biaya
        $tglMulai   = Carbon::parse($request->tgl_mulai_sewa);
        $tglAkhir   = $tglMulai->copy()->addMonths($request->durasi_sewa_bulan);
        $totalBiaya = $kamar->harga_per_bulan * $request->durasi_sewa_bulan;

        // Tambah biaya furnitur
        $furniturItems = [];
        foreach ($request->furnitur ?? [] as $item) {
            $f = Furnitur::find($item['id_furnitur']);
            if ($f) {
                $totalBiaya    += $f->harga_sewa_tambahan * $item['jumlah'] * $request->durasi_sewa_bulan;
                $furniturItems[] = ['furnitur' => $f, 'jumlah' => $item['jumlah']];
            }
        }

        // Buat booking
        $booking = Booking::create([
            'id_user'             => $request->id_user,
            'id_kamar'            => $request->id_kamar,
            'tgl_booking'         => now()->toDateString(),
            'durasi_sewa_bulan'   => $request->durasi_sewa_bulan,
            'tgl_mulai_sewa'      => $tglMulai->toDateString(),
            'tgl_akhir_sewa'      => $tglAkhir->toDateString(),
            'total_biaya_bulanan' => $totalBiaya,
            'status_booking'      => 'menunggu_pembayaran',
        ]);

        // Simpan detail furnitur
        foreach ($furniturItems as $item) {
            BookingDetailFurnitur::create([
                'id_booking'  => $booking->id_booking,
                'id_furnitur' => $item['furnitur']->id_furnitur,
                'jumlah'      => $item['jumlah'],
            ]);
        }

        // Update status kamar → terisi
        $kamar->update(['status_kamar' => 'terisi']);

        // Buat tagihan pertama
        $tagihan = Tagihan::create([
            'id_booking'     => $booking->id_booking,
            'periode_bulan'  => $tglMulai->format('Y-m-01'),
            'nominal_dasar'  => $totalBiaya,
            'nominal_denda'  => 0,
            'total_tagihan'  => $totalBiaya,
            'tgl_jatuh_tempo'=> $tglMulai->copy()->addDays(7)->toDateString(),
            'status_tagihan' => 'belum_bayar',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibuat.',
            'data'    => [
                'id_booking'  => $booking->id_booking,
                'id_tagihan'  => $tagihan->id_tagihan,
                'total_biaya' => $totalBiaya,
            ],
        ], 201);
    }

    // ── PUT /booking/{id}/batal ─────────────────────────────────
    public function batal($id)
    {
        $booking = Booking::find($id);
        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Booking tidak ditemukan.'], 404);
        }

        if (!in_array($booking->status_booking, ['menunggu_pembayaran'])) {
            return response()->json([
                'success' => false,
                'message' => 'Booking tidak dapat dibatalkan pada status ini.',
            ], 422);
        }

        $booking->update(['status_booking' => 'batal']);
        // Kembalikan status kamar
        Kamar::where('id_kamar', $booking->id_kamar)
             ->update(['status_kamar' => 'tersedia']);

        return response()->json(['success' => true, 'message' => 'Booking berhasil dibatalkan.']);
    }

    // ── Helper: format booking response ────────────────────────
    private function formatBooking(Booking $b): array
    {
        $mainFoto = $b->kamar?->galeri?->first()?->url_foto;
        $tagihanAktif = $b->tagihan?->sortByDesc('id_tagihan')->first();

        return [
            'id_booking'          => $b->id_booking,
            'id_user'             => $b->id_user,
            'id_kamar'            => $b->id_kamar,
            'tgl_booking'         => $b->tgl_booking,
            'durasi_sewa_bulan'   => $b->durasi_sewa_bulan,
            'tgl_mulai_sewa'      => $b->tgl_mulai_sewa,
            'tgl_akhir_sewa'      => $b->tgl_akhir_sewa,
            'total_biaya_bulanan' => $b->total_biaya_bulanan,
            'status_booking'      => $b->status_booking,
            'nomor_kamar'         => $b->kamar?->nomor_kamar,
            'tipe_kamar'          => $b->kamar?->tipe_kamar,
            'foto_kamar'          => $mainFoto,
            'furnitur'            => $b->furniturDetails->map(fn($d) => [
                'id_furnitur'        => $d->id_furnitur,
                'nama_furnitur'      => $d->furnitur?->nama_furnitur,
                'jumlah'             => $d->jumlah,
                'harga_sewa_tambahan'=> $d->furnitur?->harga_sewa_tambahan,
            ]),
            'tagihan'             => $tagihanAktif ? [
                'id_tagihan'     => $tagihanAktif->id_tagihan,
                'total_tagihan'  => $tagihanAktif->total_tagihan,
                'status_tagihan' => $tagihanAktif->status_tagihan,
                'tgl_jatuh_tempo'=> $tagihanAktif->tgl_jatuh_tempo,
            ] : null,
        ];
    }
}