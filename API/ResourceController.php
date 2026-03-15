<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // ── GET /user/{id} ─────────────────────────────────────────
    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id_user'    => $user->id_user,
                'nama'       => $user->nama,
                'email'      => $user->email,
                'no_telepon' => $user->no_telepon,
                'alamat'     => $user->alamat,
                'role'       => $user->role,
            ],
        ]);
    }

    // ── PUT /user/{id} ─────────────────────────────────────────
    public function update(Request $request, $id)
    {
        $request->validate([
            'nama'       => 'required|string|max:255',
            'email'      => "required|email|unique:users,email,{$id},id_user",
            'no_hp'      => 'required|string|max:20',
            'alamat'     => 'nullable|string',
        ]);

        $user = User::find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        $user->update([
            'nama'       => $request->nama,
            'email'      => $request->email,
            'no_telepon' => $request->no_hp,
            'alamat'     => $request->alamat,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => $user,
        ]);
    }
}


// ════════════════════════════════════════════════════════════════
// KAMAR CONTROLLER
// ════════════════════════════════════════════════════════════════

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Kamar;
use App\Models\GaleriKamar;
use App\Models\FasilitasKamar;
use Illuminate\Http\Request;

class KamarController extends Controller
{
    // ── GET /kamar ──────────────────────────────────────────────
    public function index()
    {
        $kamarList = Kamar::with(['galeri' => function ($q) {
            $q->where('is_main', 1);
        }])
        ->select('id_kamar', 'nomor_kamar', 'tipe_kamar', 'deskripsi',
                 'harga_per_bulan', 'status_kamar')
        ->get()
        ->map(function ($kamar) {
            $mainFoto = $kamar->galeri->first();
            $avgRating = \App\Models\Review::where('id_kamar', $kamar->id_kamar)
                ->avg('rating');

            return [
                'id_kamar'       => $kamar->id_kamar,
                'nomor_kamar'    => $kamar->nomor_kamar,
                'tipe_kamar'     => $kamar->tipe_kamar,
                'deskripsi'      => $kamar->deskripsi,
                'harga_per_bulan'=> $kamar->harga_per_bulan,
                'status_kamar'   => $kamar->status_kamar,
                'foto_primary'   => $mainFoto ? $mainFoto->url_foto : null,
                'rating'         => $avgRating ? round($avgRating, 1) : null,
            ];
        });

        return response()->json(['success' => true, 'data' => $kamarList]);
    }

    // ── GET /kamar/{id} ─────────────────────────────────────────
    public function show($id)
    {
        $kamar = Kamar::with(['galeri', 'fasilitas'])->find($id);

        if (!$kamar) {
            return response()->json(['success' => false, 'message' => 'Kamar tidak ditemukan.'], 404);
        }

        $mainFoto = $kamar->galeri->where('is_main', 1)->first();
        $avgRating = \App\Models\Review::where('id_kamar', $id)->avg('rating');

        return response()->json([
            'success' => true,
            'data'    => [
                'id_kamar'       => $kamar->id_kamar,
                'nomor_kamar'    => $kamar->nomor_kamar,
                'tipe_kamar'     => $kamar->tipe_kamar,
                'deskripsi'      => $kamar->deskripsi,
                'harga_per_bulan'=> $kamar->harga_per_bulan,
                'status_kamar'   => $kamar->status_kamar,
                'foto_primary'   => $mainFoto ? $mainFoto->url_foto : null,
                'galeri'         => $kamar->galeri->pluck('url_foto'),
                'fasilitas'      => $kamar->fasilitas->map(fn($f) => [
                    'nama'        => $f->nama_fasilitas,
                    'deskripsi'   => $f->deskripsi_fasilitas,
                ]),
                'rating'         => $avgRating ? round($avgRating, 1) : null,
            ],
        ]);
    }
}


// ════════════════════════════════════════════════════════════════
// FURNITUR CONTROLLER
// ════════════════════════════════════════════════════════════════

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Furnitur;

class FurniturController extends Controller
{
    // ── GET /furnitur ───────────────────────────────────────────
    public function index()
    {
        $furnitur = Furnitur::select(
            'id_furnitur', 'nama_furnitur', 'jumlah', 'harga_sewa_tambahan'
        )->get();

        return response()->json(['success' => true, 'data' => $furnitur]);
    }
}