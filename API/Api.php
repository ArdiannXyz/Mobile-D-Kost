<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\KamarController;
use App\Http\Controllers\API\BookingController;
use App\Http\Controllers\API\TagihanController;
use App\Http\Controllers\API\PembayaranController;
use App\Http\Controllers\API\KeluhanController;
use App\Http\Controllers\API\ReviewController;
use App\Http\Controllers\API\FurniturController;

// ── AUTH (Public) ──────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register',        [AuthController::class, 'register']);
    Route::post('/login',           [AuthController::class, 'login']);
    Route::post('/lupa-password',   [AuthController::class, 'lupaPassword']);
    Route::post('/cek-otp',         [AuthController::class, 'cekOtp']);
    Route::post('/ganti-password',  [AuthController::class, 'gantiPassword']);
});

// ── PROTECTED (Butuh Bearer Token) ────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // User
    Route::get('/user/{id}',    [UserController::class, 'show']);
    Route::put('/user/{id}',    [UserController::class, 'update']);

    // Kamar
    Route::get('/kamar',        [KamarController::class, 'index']);
    Route::get('/kamar/{id}',   [KamarController::class, 'show']);

    // Furnitur
    Route::get('/furnitur',     [FurniturController::class, 'index']);

    // Booking
    Route::post('/booking',                     [BookingController::class, 'store']);
    Route::get('/booking/user/{userId}',        [BookingController::class, 'indexByUser']);
    Route::get('/booking/{id}',                 [BookingController::class, 'show']);
    Route::put('/booking/{id}/batal',           [BookingController::class, 'batal']);

    // Tagihan
    Route::get('/tagihan/booking/{bookingId}',  [TagihanController::class, 'indexByBooking']);
    Route::get('/tagihan/{id}',                 [TagihanController::class, 'show']);

    // Pembayaran
    Route::post('/pembayaran',                  [PembayaranController::class, 'store']);
    Route::get('/pembayaran/{id}',              [PembayaranController::class, 'show']);
    Route::post('/pembayaran/callback',         [PembayaranController::class, 'callback']);

    // Keluhan
    Route::post('/keluhan',                     [KeluhanController::class, 'store']);
    Route::get('/keluhan/user/{userId}',        [KeluhanController::class, 'indexByUser']);

    // Review
    Route::post('/review',                      [ReviewController::class, 'store']);
    Route::get('/review/kamar/{kamarId}',       [ReviewController::class, 'indexByKamar']);
    Route::put('/review/{id}',                  [ReviewController::class, 'update']);
    Route::delete('/review/{id}',               [ReviewController::class, 'destroy']);
});