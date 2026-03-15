<?php
// ════════════════════════════════════════════════════════════════
// SEMUA MODELS D'KOST — sesuai ERD
// Simpan masing-masing di app/Models/NamaModel.php
// ════════════════════════════════════════════════════════════════

// ── User.php ───────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable {
    use HasApiTokens;
    protected $primaryKey = 'id_user';
    protected $fillable = ['nama','email','password','no_telepon','alamat','role'];
    protected $hidden   = ['password'];
    protected $casts    = ['created_at' => 'datetime'];

    public function bookings()  { return $this->hasMany(Booking::class, 'id_user'); }
    public function keluhanList(){ return $this->hasMany(Keluhan::class, 'id_user'); }
    public function reviews()   { return $this->hasMany(Review::class,  'id_user'); }
}

// ── Kamar.php ──────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Kamar extends Model {
    protected $primaryKey = 'id_kamar';
    public $timestamps = false;
    protected $fillable = ['nomor_kamar','tipe_kamar','deskripsi','harga_per_bulan','status_kamar'];

    public function galeri()    { return $this->hasMany(GaleriKamar::class,    'id_kamar'); }
    public function fasilitas() { return $this->hasMany(FasilitasKamar::class, 'id_kamar'); }
    public function bookings()  { return $this->hasMany(Booking::class,        'id_kamar'); }
    public function reviews()   { return $this->hasMany(Review::class,         'id_kamar'); }
}

// ── GaleriKamar.php ────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class GaleriKamar extends Model {
    protected $primaryKey = 'id_foto';
    public $timestamps = false;
    protected $fillable = ['id_kamar','url_foto','is_main'];
    public function kamar() { return $this->belongsTo(Kamar::class, 'id_kamar'); }
}

// ── FasilitasKamar.php ─────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class FasilitasKamar extends Model {
    protected $primaryKey = 'id_fasilitas';
    public $timestamps = false;
    protected $fillable = ['id_kamar','nama_fasilitas','deskripsi_fasilitas'];
    public function kamar() { return $this->belongsTo(Kamar::class, 'id_kamar'); }
}

// ── Furnitur.php ───────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Furnitur extends Model {
    protected $primaryKey = 'id_furnitur';
    public $timestamps = false;
    protected $fillable = ['nama_furnitur','jumlah','harga_sewa_tambahan'];
    public function bookingDetails() { return $this->hasMany(BookingDetailFurnitur::class, 'id_furnitur'); }
}

// ── Booking.php ────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model {
    protected $primaryKey = 'id_booking';
    public $timestamps = false;
    protected $fillable = [
        'id_user','id_kamar','tgl_booking','durasi_sewa_bulan',
        'tgl_mulai_sewa','tgl_akhir_sewa','total_biaya_bulanan','status_booking',
    ];

    public function user()            { return $this->belongsTo(User::class,   'id_user'); }
    public function kamar()           { return $this->belongsTo(Kamar::class,  'id_kamar'); }
    public function furniturDetails() { return $this->hasMany(BookingDetailFurnitur::class, 'id_booking'); }
    public function tagihan()         { return $this->hasMany(Tagihan::class,  'id_booking'); }
}

// ── BookingDetailFurnitur.php ──────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class BookingDetailFurnitur extends Model {
    protected $primaryKey = 'id_detail';
    public $timestamps = false;
    protected $fillable = ['id_booking','id_furnitur','jumlah'];
    public function booking()  { return $this->belongsTo(Booking::class,  'id_booking'); }
    public function furnitur() { return $this->belongsTo(Furnitur::class, 'id_furnitur'); }
}

// ── Tagihan.php ────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Tagihan extends Model {
    protected $primaryKey = 'id_tagihan';
    public $timestamps = false;
    protected $fillable = [
        'id_booking','periode_bulan','nominal_dasar','nominal_denda',
        'total_tagihan','tgl_jatuh_tempo','status_tagihan',
    ];
    public function booking()    { return $this->belongsTo(Booking::class,    'id_booking'); }
    public function pembayaran() { return $this->hasMany(Pembayaran::class,   'id_tagihan'); }
}

// ── Pembayaran.php ─────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model {
    protected $primaryKey = 'id_pembayaran';
    public $timestamps = false;
    protected $fillable = [
        'id_tagihan','order_id','snap_token','transaction_id_gateway',
        'tgl_bayar','jumlah_bayar','metode_pembayaran','status_pembayaran',
    ];
    public function tagihan()   { return $this->belongsTo(Tagihan::class,    'id_tagihan'); }
    public function pendapatan(){ return $this->hasOne(Pendapatan::class,    'id_pembayaran'); }
}

// ── Keluhan.php ────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Keluhan extends Model {
    protected $primaryKey = 'id_keluhan';
    public $timestamps = false;
    protected $fillable = ['id_user','id_kamar','deskripsi_masalah','foto_bukti','tgl_lapor','status_keluhan'];
    public function user()  { return $this->belongsTo(User::class,  'id_user'); }
    public function kamar() { return $this->belongsTo(Kamar::class, 'id_kamar'); }
}

// ── Review.php ─────────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Review extends Model {
    protected $primaryKey = 'id_review';
    public $timestamps = false;
    protected $fillable = ['id_user','id_kamar','rating','komentar','tgl_review'];
    public function user()  { return $this->belongsTo(User::class,  'id_user'); }
    public function kamar() { return $this->belongsTo(Kamar::class, 'id_kamar'); }
}

// ── Pendapatan.php ─────────────────────────────────────────────
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Pendapatan extends Model {
    protected $primaryKey = 'id_pendapatan';
    public $timestamps = false;
    protected $fillable = ['id_pembayaran','nominal','tgl_diterima'];
    public function pembayaran() { return $this->belongsTo(Pembayaran::class, 'id_pembayaran'); }
}