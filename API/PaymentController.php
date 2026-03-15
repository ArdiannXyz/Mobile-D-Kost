<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Tagihan;
use App\Models\Pembayaran;
use App\Models\Pendapatan;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

// ════════════════════════════════════════════════════════════════
// TAGIHAN CONTROLLER
// ════════════════════════════════════════════════════════════════
class TagihanController extends Controller
{
    // ── GET /tagihan/booking/{bookingId} ────────────────────────
    public function indexByBooking($bookingId)
    {
        $tagihanList = Tagihan::where('id_booking', $bookingId)
            ->orderByDesc('periode_bulan')
            ->get();

        return response()->json(['success' => true, 'data' => $tagihanList]);
    }

    // ── GET /tagihan/{id} ───────────────────────────────────────
    public function show($id)
    {
        $tagihan = Tagihan::with('booking.kamar')->find($id);

        if (!$tagihan) {
            return response()->json(['success' => false, 'message' => 'Tagihan tidak ditemukan.'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id_tagihan'     => $tagihan->id_tagihan,
                'id_booking'     => $tagihan->id_booking,
                'periode_bulan'  => $tagihan->periode_bulan,
                'nominal_dasar'  => $tagihan->nominal_dasar,
                'nominal_denda'  => $tagihan->nominal_denda,
                'total_tagihan'  => $tagihan->total_tagihan,
                'tgl_jatuh_tempo'=> $tagihan->tgl_jatuh_tempo,
                'status_tagihan' => $tagihan->status_tagihan,
                'kamar'          => [
                    'nomor_kamar' => $tagihan->booking?->kamar?->nomor_kamar,
                    'tipe_kamar'  => $tagihan->booking?->kamar?->tipe_kamar,
                ],
            ],
        ]);
    }
}


// ════════════════════════════════════════════════════════════════
// PEMBAYARAN CONTROLLER
// ════════════════════════════════════════════════════════════════
class PembayaranController extends Controller
{
    // ── POST /pembayaran — buat transaksi Midtrans ──────────────
    public function store(Request $request)
    {
        $request->validate([
            'id_tagihan' => 'required|exists:tagihan,id_tagihan',
        ]);

        $tagihan = Tagihan::with('booking.user')->find($request->id_tagihan);

        if ($tagihan->status_tagihan === 'lunas') {
            return response()->json([
                'success' => false,
                'message' => 'Tagihan ini sudah lunas.',
            ], 422);
        }

        // Generate order_id unik
        $orderId = 'DKOST-' . $tagihan->id_tagihan . '-' . Str::upper(Str::random(6));

        // ── Midtrans Snap Token ─────────────────────────────────
        \Midtrans\Config::$serverKey    = config('midtrans.server_key');
        \Midtrans\Config::$isProduction = config('midtrans.is_production');
        \Midtrans\Config::$isSanitized  = true;
        \Midtrans\Config::$is3ds        = true;

        $params = [
            'transaction_details' => [
                'order_id'     => $orderId,
                'gross_amount' => (int) $tagihan->total_tagihan,
            ],
            'customer_details' => [
                'first_name' => $tagihan->booking?->user?->nama ?? 'Penyewa',
                'email'      => $tagihan->booking?->user?->email ?? '',
                'phone'      => $tagihan->booking?->user?->no_telepon ?? '',
            ],
            'item_details' => [
                [
                    'id'       => 'tagihan-' . $tagihan->id_tagihan,
                    'price'    => (int) $tagihan->total_tagihan,
                    'quantity' => 1,
                    'name'     => 'Tagihan Kost Periode ' . $tagihan->periode_bulan,
                ],
            ],
        ];

        try {
            $snapToken = \Midtrans\Snap::getSnapToken($params);

            // Simpan record pembayaran
            $pembayaran = Pembayaran::create([
                'id_tagihan'               => $tagihan->id_tagihan,
                'order_id'                 => $orderId,
                'snap_token'               => $snapToken,
                'transaction_id_gateway'   => null,
                'tgl_bayar'                => null,
                'jumlah_bayar'             => $tagihan->total_tagihan,
                'metode_pembayaran'        => null,
                'status_pembayaran'        => 'pending',
            ]);

            return response()->json([
                'success'    => true,
                'message'    => 'Transaksi berhasil dibuat.',
                'data'       => [
                    'id_pembayaran' => $pembayaran->id_pembayaran,
                    'order_id'      => $orderId,
                    'snap_token'    => $snapToken,
                    'total'         => $tagihan->total_tagihan,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat transaksi: ' . $e->getMessage(),
            ], 500);
        }
    }

    // ── GET /pembayaran/{id} ────────────────────────────────────
    public function show($id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json(['success' => false, 'message' => 'Data pembayaran tidak ditemukan.'], 404);
        }

        return response()->json(['success' => true, 'data' => $pembayaran]);
    }

    // ── POST /pembayaran/callback — Midtrans Notification ───────
    public function callback(Request $request)
    {
        \Midtrans\Config::$serverKey    = config('midtrans.server_key');
        \Midtrans\Config::$isProduction = config('midtrans.is_production');

        $notification = new \Midtrans\Notification();

        $orderId           = $notification->order_id;
        $transactionStatus = $notification->transaction_status;
        $transactionId     = $notification->transaction_id;
        $paymentType       = $notification->payment_type;
        $fraudStatus       = $notification->fraud_status;

        $pembayaran = Pembayaran::where('order_id', $orderId)->first();
        if (!$pembayaran) return response('Not found', 404);

        // Tentukan status berdasarkan response Midtrans
        $status = match (true) {
            $transactionStatus === 'settlement'                                    => 'settlement',
            $transactionStatus === 'capture' && $fraudStatus === 'accept'         => 'settlement',
            $transactionStatus === 'pending'                                       => 'pending',
            in_array($transactionStatus, ['cancel', 'deny'])                      => 'cancel',
            $transactionStatus === 'expire'                                        => 'expire',
            default                                                                => 'pending',
        };

        $pembayaran->update([
            'transaction_id_gateway' => $transactionId,
            'metode_pembayaran'      => $paymentType,
            'status_pembayaran'      => $status,
            'tgl_bayar'              => $status === 'settlement' ? now() : null,
        ]);

        // Jika berhasil bayar → update tagihan & booking
        if ($status === 'settlement') {
            $tagihan = Tagihan::find($pembayaran->id_tagihan);
            $tagihan?->update(['status_tagihan' => 'lunas']);

            $booking = Booking::find($tagihan?->id_booking);
            $booking?->update(['status_booking' => 'aktif']);

            // Catat pendapatan
            Pendapatan::create([
                'id_pembayaran' => $pembayaran->id_pembayaran,
                'nominal'       => $pembayaran->jumlah_bayar,
                'tgl_diterima'  => now()->toDateString(),
            ]);
        }

        return response('OK', 200);
    }
}