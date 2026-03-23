-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 13, 2026 at 03:07 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dkost`
--

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

CREATE TABLE `booking` (
  `id_booking` int NOT NULL,
  `id_user` int DEFAULT NULL,
  `id_kamar` int DEFAULT NULL,
  `tgl_booking` date NOT NULL,
  `durasi_sewa_bulan` int NOT NULL,
  `tgl_mulai_sewa` date DEFAULT NULL,
  `tgl_akhir_sewa` date DEFAULT NULL,
  `total_biaya_bulanan` decimal(15,2) DEFAULT NULL,
  `status_booking` enum('menunggu_pembayaran','aktif','selesai','batal','expired') DEFAULT 'menunggu_pembayaran'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_detail_furnitur`
--

CREATE TABLE `booking_detail_furnitur` (
  `id_detail` int NOT NULL,
  `id_booking` int DEFAULT NULL,
  `id_furnitur` int DEFAULT NULL,
  `jumlah` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fasilitas_kamar`
--

CREATE TABLE `fasilitas_kamar` (
  `id_fasilitas` int NOT NULL,
  `id_kamar` int DEFAULT NULL,
  `nama_fasilitas` varchar(255) NOT NULL,
  `deskripsi_fasilitas` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `furnitur`
--

CREATE TABLE `furnitur` (
  `id_furnitur` int NOT NULL,
  `nama_furnitur` varchar(255) NOT NULL,
  `jumlah` int DEFAULT '0',
  `harga_sewa_tambahan` decimal(15,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `galeri_kamar`
--

CREATE TABLE `galeri_kamar` (
  `id_foto` int NOT NULL,
  `id_kamar` int DEFAULT NULL,
  `url_foto` varchar(255) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kamar`
--

CREATE TABLE `kamar` (
  `id_kamar` int NOT NULL,
  `nomor_kamar` varchar(50) NOT NULL,
  `tipe_kamar` enum('biasa','sedang','mewah') NOT NULL,
  `deskripsi` text,
  `harga_per_bulan` decimal(15,2) NOT NULL,
  `status_kamar` enum('tersedia','terisi','maintenance') DEFAULT 'tersedia'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `keluhan`
--

CREATE TABLE `keluhan` (
  `id_keluhan` int NOT NULL,
  `id_user` int DEFAULT NULL,
  `id_kamar` int DEFAULT NULL,
  `deskripsi_masalah` text NOT NULL,
  `foto_bukti` varchar(255) DEFAULT NULL,
  `tgl_lapor` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status_keluhan` enum('pending','diproses','selesai') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `id_pembayaran` int NOT NULL,
  `id_tagihan` int DEFAULT NULL,
  `order_id` varchar(255) NOT NULL,
  `snap_token` varchar(255) DEFAULT NULL,
  `transaction_id_gateway` varchar(255) DEFAULT NULL,
  `tgl_bayar` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `jumlah_bayar` decimal(15,2) DEFAULT NULL,
  `metode_pembayaran` varchar(50) DEFAULT NULL,
  `status_pembayaran` enum('pending','settlement','expire','cancel','deny') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pendapatan`
--

CREATE TABLE `pendapatan` (
  `id_pendapatan` int NOT NULL,
  `id_pembayaran` int DEFAULT NULL,
  `nominal` decimal(15,2) NOT NULL,
  `tgl_diterima` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengeluaran`
--

CREATE TABLE `pengeluaran` (
  `id_pengeluaran` int NOT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `nominal` decimal(15,2) NOT NULL,
  `keterangan` text,
  `tgl_transaksi` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `review`
--

CREATE TABLE `review` (
  `id_review` int NOT NULL,
  `id_user` int DEFAULT NULL,
  `id_kamar` int DEFAULT NULL,
  `rating` int DEFAULT NULL,
  `komentar` text,
  `tgl_review` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tagihan`
--

CREATE TABLE `tagihan` (
  `id_tagihan` int NOT NULL,
  `id_booking` int DEFAULT NULL,
  `periode_bulan` date DEFAULT NULL,
  `nominal_dasar` decimal(15,2) DEFAULT NULL,
  `nominal_denda` decimal(15,2) DEFAULT '0.00',
  `total_tagihan` decimal(15,2) DEFAULT NULL,
  `tgl_jatuh_tempo` date DEFAULT NULL,
  `status_tagihan` enum('belum_bayar','lunas','terlambat') DEFAULT 'belum_bayar'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_user` int NOT NULL,
  `nama` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `alamat` text,
  `role` enum('admin','penyewa') DEFAULT 'penyewa',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`id_booking`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_kamar` (`id_kamar`);

--
-- Indexes for table `booking_detail_furnitur`
--
ALTER TABLE `booking_detail_furnitur`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_booking` (`id_booking`),
  ADD KEY `id_furnitur` (`id_furnitur`);

--
-- Indexes for table `fasilitas_kamar`
--
ALTER TABLE `fasilitas_kamar`
  ADD PRIMARY KEY (`id_fasilitas`),
  ADD KEY `id_kamar` (`id_kamar`);

--
-- Indexes for table `furnitur`
--
ALTER TABLE `furnitur`
  ADD PRIMARY KEY (`id_furnitur`);

--
-- Indexes for table `galeri_kamar`
--
ALTER TABLE `galeri_kamar`
  ADD PRIMARY KEY (`id_foto`),
  ADD KEY `id_kamar` (`id_kamar`);

--
-- Indexes for table `kamar`
--
ALTER TABLE `kamar`
  ADD PRIMARY KEY (`id_kamar`),
  ADD UNIQUE KEY `nomor_kamar` (`nomor_kamar`);

--
-- Indexes for table `keluhan`
--
ALTER TABLE `keluhan`
  ADD PRIMARY KEY (`id_keluhan`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_kamar` (`id_kamar`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`id_pembayaran`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD KEY `id_tagihan` (`id_tagihan`);

--
-- Indexes for table `pendapatan`
--
ALTER TABLE `pendapatan`
  ADD PRIMARY KEY (`id_pendapatan`),
  ADD KEY `id_pembayaran` (`id_pembayaran`);

--
-- Indexes for table `pengeluaran`
--
ALTER TABLE `pengeluaran`
  ADD PRIMARY KEY (`id_pengeluaran`);

--
-- Indexes for table `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`id_review`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_kamar` (`id_kamar`);

--
-- Indexes for table `tagihan`
--
ALTER TABLE `tagihan`
  ADD PRIMARY KEY (`id_tagihan`),
  ADD KEY `id_booking` (`id_booking`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `booking`
--
ALTER TABLE `booking`
  MODIFY `id_booking` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `booking_detail_furnitur`
--
ALTER TABLE `booking_detail_furnitur`
  MODIFY `id_detail` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fasilitas_kamar`
--
ALTER TABLE `fasilitas_kamar`
  MODIFY `id_fasilitas` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `furnitur`
--
ALTER TABLE `furnitur`
  MODIFY `id_furnitur` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `galeri_kamar`
--
ALTER TABLE `galeri_kamar`
  MODIFY `id_foto` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kamar`
--
ALTER TABLE `kamar`
  MODIFY `id_kamar` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `keluhan`
--
ALTER TABLE `keluhan`
  MODIFY `id_keluhan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `id_pembayaran` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pendapatan`
--
ALTER TABLE `pendapatan`
  MODIFY `id_pendapatan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengeluaran`
--
ALTER TABLE `pengeluaran`
  MODIFY `id_pengeluaran` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `review`
--
ALTER TABLE `review`
  MODIFY `id_review` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tagihan`
--
ALTER TABLE `tagihan`
  MODIFY `id_tagihan` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`);

--
-- Constraints for table `booking_detail_furnitur`
--
ALTER TABLE `booking_detail_furnitur`
  ADD CONSTRAINT `booking_detail_furnitur_ibfk_1` FOREIGN KEY (`id_booking`) REFERENCES `booking` (`id_booking`) ON DELETE CASCADE,
  ADD CONSTRAINT `booking_detail_furnitur_ibfk_2` FOREIGN KEY (`id_furnitur`) REFERENCES `furnitur` (`id_furnitur`);

--
-- Constraints for table `fasilitas_kamar`
--
ALTER TABLE `fasilitas_kamar`
  ADD CONSTRAINT `fasilitas_kamar_ibfk_1` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`) ON DELETE CASCADE;

--
-- Constraints for table `galeri_kamar`
--
ALTER TABLE `galeri_kamar`
  ADD CONSTRAINT `galeri_kamar_ibfk_1` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`) ON DELETE CASCADE;

--
-- Constraints for table `keluhan`
--
ALTER TABLE `keluhan`
  ADD CONSTRAINT `keluhan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `keluhan_ibfk_2` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`);

--
-- Constraints for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD CONSTRAINT `pembayaran_ibfk_1` FOREIGN KEY (`id_tagihan`) REFERENCES `tagihan` (`id_tagihan`);

--
-- Constraints for table `pendapatan`
--
ALTER TABLE `pendapatan`
  ADD CONSTRAINT `pendapatan_ibfk_1` FOREIGN KEY (`id_pembayaran`) REFERENCES `pembayaran` (`id_pembayaran`);

--
-- Constraints for table `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`);

--
-- Constraints for table `tagihan`
--
ALTER TABLE `tagihan`
  ADD CONSTRAINT `tagihan_ibfk_1` FOREIGN KEY (`id_booking`) REFERENCES `booking` (`id_booking`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
