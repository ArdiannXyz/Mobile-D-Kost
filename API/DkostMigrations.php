<?php
// ════════════════════════════════════════════════════════════════
// MIGRATIONS D'KOST — sesuai ERD
// Jalankan: php artisan migrate
// ════════════════════════════════════════════════════════════════

// ── create_users_table ─────────────────────────────────────────
Schema::create('users', function (Blueprint $table) {
    $table->increments('id_user');
    $table->string('nama');
    $table->string('email')->unique();
    $table->string('password');
    $table->string('no_telepon', 20)->nullable();
    $table->text('alamat')->nullable();
    $table->enum('role', ['admin', 'penyewa'])->default('penyewa');
    $table->timestamp('created_at')->useCurrent();
});

// ── create_personal_access_tokens (Sanctum) ───────────────────
Schema::create('personal_access_tokens', function (Blueprint $table) {
    $table->bigIncrements('id');
    $table->morphs('tokenable');
    $table->string('name');
    $table->string('token', 64)->unique();
    $table->text('abilities')->nullable();
    $table->timestamp('last_used_at')->nullable();
    $table->timestamp('expires_at')->nullable();
    $table->timestamps();
});

// ── create_kamar_table ─────────────────────────────────────────
Schema::create('kamar', function (Blueprint $table) {
    $table->increments('id_kamar');
    $table->string('nomor_kamar', 20)->unique();
    $table->enum('tipe_kamar', ['biasa', 'sedang', 'mewah']);
    $table->text('deskripsi')->nullable();
    $table->decimal('harga_per_bulan', 10, 2);
    $table->enum('status_kamar', ['tersedia', 'terisi', 'maintenance'])->default('tersedia');
});

// ── create_galeri_kamar_table ──────────────────────────────────
Schema::create('galeri_kamar', function (Blueprint $table) {
    $table->increments('id_foto');
    $table->unsignedInteger('id_kamar');
    $table->string('url_foto');          // URL ke storage, bukan BLOB
    $table->tinyInteger('is_main')->default(0);
    $table->foreign('id_kamar')->references('id_kamar')->on('kamar')->onDelete('cascade');
});

// ── create_fasilitas_kamar_table ───────────────────────────────
Schema::create('fasilitas_kamar', function (Blueprint $table) {
    $table->increments('id_fasilitas');
    $table->unsignedInteger('id_kamar');
    $table->string('nama_fasilitas');
    $table->text('deskripsi_fasilitas')->nullable();
    $table->foreign('id_kamar')->references('id_kamar')->on('kamar')->onDelete('cascade');
});

// ── create_furnitur_table ──────────────────────────────────────
Schema::create('furnitur', function (Blueprint $table) {
    $table->increments('id_furnitur');
    $table->string('nama_furnitur');
    $table->integer('jumlah')->default(0);
    $table->decimal('harga_sewa_tambahan', 10, 2)->default(0);
});

// ── create_booking_table ───────────────────────────────────────
Schema::create('booking', function (Blueprint $table) {
    $table->increments('id_booking');
    $table->unsignedInteger('id_user');
    $table->unsignedInteger('id_kamar');
    $table->date('tgl_booking');
    $table->integer('durasi_sewa_bulan');
    $table->date('tgl_mulai_sewa');
    $table->date('tgl_akhir_sewa');
    $table->decimal('total_biaya_bulanan', 12, 2);
    $table->enum('status_booking', ['menunggu_pembayaran','aktif','selesai','batal','expired'])
          ->default('menunggu_pembayaran');
    $table->foreign('id_user')->references('id_user')->on('users');
    $table->foreign('id_kamar')->references('id_kamar')->on('kamar');
});

// ── create_booking_detail_furnitur_table ───────────────────────
Schema::create('booking_detail_furnitur', function (Blueprint $table) {
    $table->increments('id_detail');
    $table->unsignedInteger('id_booking');
    $table->unsignedInteger('id_furnitur');
    $table->integer('jumlah');
    $table->foreign('id_booking')->references('id_booking')->on('booking')->onDelete('cascade');
    $table->foreign('id_furnitur')->references('id_furnitur')->on('furnitur');
});

// ── create_tagihan_table ───────────────────────────────────────
Schema::create('tagihan', function (Blueprint $table) {
    $table->increments('id_tagihan');
    $table->unsignedInteger('id_booking');
    $table->date('periode_bulan');
    $table->decimal('nominal_dasar', 12, 2);
    $table->decimal('nominal_denda', 12, 2)->default(0);
    $table->decimal('total_tagihan', 12, 2);
    $table->date('tgl_jatuh_tempo');
    $table->enum('status_tagihan', ['belum_bayar', 'lunas', 'terlambat'])->default('belum_bayar');
    $table->foreign('id_booking')->references('id_booking')->on('booking')->onDelete('cascade');
});

// ── create_pembayaran_table ────────────────────────────────────
Schema::create('pembayaran', function (Blueprint $table) {
    $table->increments('id_pembayaran');
    $table->unsignedInteger('id_tagihan');
    $table->string('order_id')->unique();
    $table->text('snap_token')->nullable();
    $table->string('transaction_id_gateway')->nullable();
    $table->timestamp('tgl_bayar')->nullable();
    $table->decimal('jumlah_bayar', 12, 2);
    $table->string('metode_pembayaran')->nullable();
    $table->enum('status_pembayaran', ['pending','settlement','expire','cancel','deny'])->default('pending');
    $table->foreign('id_tagihan')->references('id_tagihan')->on('tagihan');
});

// ── create_keluhan_table ───────────────────────────────────────
Schema::create('keluhan', function (Blueprint $table) {
    $table->increments('id_keluhan');
    $table->unsignedInteger('id_user');
    $table->unsignedInteger('id_kamar');
    $table->text('deskripsi_masalah');
    $table->string('foto_bukti')->nullable();
    $table->timestamp('tgl_lapor')->useCurrent();
    $table->enum('status_keluhan', ['pending', 'diproses', 'selesai'])->default('pending');
    $table->foreign('id_user')->references('id_user')->on('users');
    $table->foreign('id_kamar')->references('id_kamar')->on('kamar');
});

// ── create_review_table ────────────────────────────────────────
Schema::create('review', function (Blueprint $table) {
    $table->increments('id_review');
    $table->unsignedInteger('id_user');
    $table->unsignedInteger('id_kamar');
    $table->integer('rating')->unsigned();
    $table->text('komentar')->nullable();
    $table->timestamp('tgl_review')->useCurrent();
    $table->unique(['id_user', 'id_kamar']); // 1 user = 1 review per kamar
    $table->foreign('id_user')->references('id_user')->on('users');
    $table->foreign('id_kamar')->references('id_kamar')->on('kamar');
});

// ── create_pengeluaran_table ───────────────────────────────────
Schema::create('pengeluaran', function (Blueprint $table) {
    $table->increments('id_pengeluaran');
    $table->string('kategori');
    $table->decimal('nominal', 12, 2);
    $table->text('keterangan')->nullable();
    $table->date('tgl_transaksi');
});

// ── create_pendapatan_table ────────────────────────────────────
Schema::create('pendapatan', function (Blueprint $table) {
    $table->increments('id_pendapatan');
    $table->unsignedInteger('id_pembayaran');
    $table->decimal('nominal', 12, 2);
    $table->date('tgl_diterima');
    $table->foreign('id_pembayaran')->references('id_pembayaran')->on('pembayaran');
});