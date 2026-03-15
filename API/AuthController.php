<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;

class AuthController extends Controller
{
    // ── Register ───────────────────────────────────────────────
    public function register(Request $request)
    {
        $request->validate([
            'nama'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'no_hp'    => 'required|string|max:20',
            'password' => 'required|string|min:6',
            'role'     => 'in:admin,penyewa',
        ]);

        $user = User::create([
            'nama'     => $request->nama,
            'email'    => $request->email,
            'no_telepon' => $request->no_hp,
            'password' => Hash::make($request->password),
            'role'     => $request->role ?? 'penyewa',
        ]);

        return response()->json([
            'error'   => false,
            'message' => 'Registrasi berhasil.',
            'data'    => $user,
        ], 201);
    }

    // ── Login ──────────────────────────────────────────────────
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'error'   => true,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // Hanya penyewa yang bisa login di app mobile
        if ($user->role !== 'penyewa') {
            return response()->json([
                'error'   => true,
                'message' => 'Akun ini tidak memiliki akses ke aplikasi mobile.',
            ], 403);
        }

        $token = $user->createToken('dkost-mobile')->plainTextToken;

        return response()->json([
            'error'   => false,
            'message' => 'Login berhasil.',
            'token'   => $token,
            'user'    => [
                'id_user' => $user->id_user,
                'nama'    => $user->nama,
                'email'   => $user->email,
                'role'    => $user->role,
            ],
        ]);
    }

    // ── Logout ─────────────────────────────────────────────────
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'error'   => false,
            'message' => 'Logout berhasil.',
        ]);
    }

    // ── Lupa Password (kirim OTP) ──────────────────────────────
    public function lupaPassword(Request $request)
    {
        $request->validate(['email' => 'required|email|exists:users,email']);

        // Generate OTP 6 digit
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Simpan OTP di cache selama 10 menit
        Cache::put("otp_{$request->email}", $otp, now()->addMinutes(10));

        // TODO: Kirim OTP via email (Mail::to($request->email)->send(...))
        // Untuk development, OTP dikembalikan di response
        return response()->json([
            'error'   => false,
            'message' => "Kode OTP telah dikirim ke {$request->email}.",
            // 'otp' => $otp, // Hapus di production
        ]);
    }

    // ── Cek OTP ────────────────────────────────────────────────
    public function cekOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp'   => 'required|digits:6',
        ]);

        $cachedOtp = Cache::get("otp_{$request->email}");

        if (!$cachedOtp || $cachedOtp !== $request->otp) {
            return response()->json([
                'error'   => true,
                'message' => 'Kode OTP tidak valid atau sudah kadaluarsa.',
            ], 422);
        }

        // Tandai OTP sebagai terverifikasi
        Cache::put("otp_verified_{$request->email}", true, now()->addMinutes(10));
        Cache::forget("otp_{$request->email}");

        return response()->json([
            'error'   => false,
            'message' => 'OTP valid.',
        ]);
    }

    // ── Ganti Password ─────────────────────────────────────────
    public function gantiPassword(Request $request)
    {
        $request->validate([
            'email'                 => 'required|email|exists:users,email',
            'password'              => 'required|string|min:6',
            'password_confirmation' => 'required|same:password',
        ]);

        // Cek apakah OTP sudah diverifikasi
        if (!Cache::get("otp_verified_{$request->email}")) {
            return response()->json([
                'error'   => true,
                'message' => 'Verifikasi OTP diperlukan sebelum ganti password.',
            ], 403);
        }

        User::where('email', $request->email)
            ->update(['password' => Hash::make($request->password)]);

        Cache::forget("otp_verified_{$request->email}");

        return response()->json([
            'error'   => false,
            'message' => 'Password berhasil diubah. Silakan login kembali.',
        ]);
    }
}