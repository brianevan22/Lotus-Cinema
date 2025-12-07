-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 07 Des 2025 pada 05.10
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bioskop`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `id_users` bigint(20) UNSIGNED DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`customer_id`, `id_users`, `nama`, `email`, `no_hp`) VALUES
(11, 5, 'Brian Evan', 'brianevan22@gmail.com', '085108815888'),
(12, 6, 'Dilla Ayu', 'dillaayu@gmail.com', '085806844421'),
(13, 7, 'Amarrazan Yuka', 'amarrazanyn@gmail.com', '085645567856');

-- --------------------------------------------------------

--
-- Struktur dari tabel `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `detail_id` int(11) NOT NULL,
  `transaksi_id` int(11) DEFAULT NULL,
  `tiket_id` int(11) DEFAULT NULL,
  `film_id` int(11) NOT NULL,
  `harga` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `detail_transaksi`
--

INSERT INTO `detail_transaksi` (`detail_id`, `transaksi_id`, `tiket_id`, `film_id`, `harga`) VALUES
(118, 64, 262, 2, 100000.00),
(119, 65, 263, 2, 100000.00),
(120, 66, 264, 2, 100000.00),
(121, 67, 425, 5, 65000.00),
(129, 75, 392, 1, 75000.00),
(130, 76, 426, 5, 65000.00),
(131, 77, 393, 1, 75000.00),
(132, 77, 394, 1, 75000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `film`
--

CREATE TABLE `film` (
  `film_id` int(11) NOT NULL,
  `judul` varchar(200) NOT NULL,
  `durasi` int(11) NOT NULL,
  `sinopsis` text DEFAULT NULL,
  `genre_id` int(11) DEFAULT NULL,
  `harga` int(11) NOT NULL DEFAULT 0,
  `poster` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `film`
--

INSERT INTO `film` (`film_id`, `judul`, `durasi`, `sinopsis`, `genre_id`, `harga`, `poster`) VALUES
(1, 'Avengers: Endgame', 181, 'Pertarungan terakhir melawan Thanos demi menyelamatkan alam semesta.', 1, 75000, 'Avangers_EndGame.png'),
(2, 'Laskar Pelangi', 120, 'Kisah anak-anak di Belitung yang penuh semangat meraih mimpi.', 2, 60000, 'LaskarPelangi.png'),
(3, 'My Stupid Boss', 110, 'Komedian karyawan yang menghadapi bos eksentrik.', 3, 55000, 'MyStupidBoss.png'),
(4, 'Pengabdi Setan', 107, 'Keluarga diteror makhluk gaib setelah kematian ibu.', 4, 70000, 'PengabdiSetan.png'),
(5, 'Toy Story 4', 100, 'Petualangan Woody, Buzz dan mainan lainnya menemukan arti keluarga.', 5, 65000, 'ToyStory_4.png');

-- --------------------------------------------------------

--
-- Struktur dari tabel `genre`
--

CREATE TABLE `genre` (
  `genre_id` int(11) NOT NULL,
  `nama_genre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `genre`
--

INSERT INTO `genre` (`genre_id`, `nama_genre`) VALUES
(1, 'Action'),
(2, 'Drama'),
(3, 'Komedi'),
(4, 'Horror'),
(5, 'Animation');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jadwal`
--

CREATE TABLE `jadwal` (
  `jadwal_id` int(11) NOT NULL,
  `film_id` int(11) DEFAULT NULL,
  `studio_id` int(11) DEFAULT NULL,
  `tanggal` date NOT NULL,
  `jam_mulai` time NOT NULL,
  `jam_selesai` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `jadwal`
--

INSERT INTO `jadwal` (`jadwal_id`, `film_id`, `studio_id`, `tanggal`, `jam_mulai`, `jam_selesai`) VALUES
(2, 3, 1, '2025-11-27', '12:00:00', '13:50:00'),
(3, 5, 2, '2025-10-23', '15:00:00', '16:40:00'),
(13, 1, 3, '2025-11-20', '15:10:00', '17:10:00'),
(14, 4, 2, '2025-11-19', '18:10:00', '20:10:00'),
(16, 2, 2, '2025-11-04', '16:00:00', '19:00:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `kasir`
--

CREATE TABLE `kasir` (
  `kasir_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `shift` enum('pagi','siang','malam') NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kasir`
--

INSERT INTO `kasir` (`kasir_id`, `nama`, `shift`, `no_hp`) VALUES
(1, 'Brian Evan', 'pagi', '081222334455'),
(2, 'Amarrazan', 'siang', '082233445566'),
(3, 'Ammar Gibran', 'malam', '083344556677');

-- --------------------------------------------------------

--
-- Struktur dari tabel `komentar`
--

CREATE TABLE `komentar` (
  `komentar_id` int(11) NOT NULL,
  `users_id` int(11) NOT NULL,
  `film_id` int(11) DEFAULT NULL,
  `isi_komentar` text NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `tanggal` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `komentar`
--

INSERT INTO `komentar` (`komentar_id`, `users_id`, `film_id`, `isi_komentar`, `rating`, `tanggal`) VALUES
(1, 6, 2, 'Filmnya sangat inspiratif dan juga memotivasi untuk tetap semangat belajar', 5, '2025-11-11'),
(2, 6, 3, 'Ceritanya lucu banget dan juga alurnya tidak membosankan', 5, '2025-11-11'),
(3, 5, 4, 'Vibes seremnya dapet banget dan juga alur ceritanya yang gak seperti film horror pada umumnya', 4, '2025-11-11'),
(14, 5, 5, 'keren jir', 4, '2025-11-11'),
(16, 5, 4, 'takutnyee', 5, '2025-11-11'),
(41, 1, 2, 'Apakah Seru?', 5, '2025-11-11');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kursi`
--

CREATE TABLE `kursi` (
  `kursi_id` int(11) NOT NULL,
  `nomor_kursi` varchar(10) NOT NULL,
  `studio_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kursi`
--

INSERT INTO `kursi` (`kursi_id`, `nomor_kursi`, `studio_id`) VALUES
(1, 'A1', 1),
(102, 'A1', 2),
(170, 'A1', 3),
(10, 'A10', 1),
(97, 'A11', 1),
(98, 'A12', 1),
(99, 'A13', 1),
(100, 'A14', 1),
(101, 'A15', 1),
(2, 'A2', 1),
(103, 'A2', 2),
(171, 'A2', 3),
(3, 'A3', 1),
(104, 'A3', 2),
(172, 'A3', 3),
(4, 'A4', 1),
(105, 'A4', 2),
(173, 'A4', 3),
(5, 'A5', 1),
(106, 'A5', 2),
(174, 'A5', 3),
(6, 'A6', 1),
(107, 'A6', 2),
(175, 'A6', 3),
(7, 'A7', 1),
(108, 'A7', 2),
(176, 'A7', 3),
(8, 'A8', 1),
(109, 'A8', 2),
(177, 'A8', 3),
(9, 'A9', 1),
(136, 'B1', 1),
(11, 'B1', 2),
(178, 'B1', 3),
(82, 'B10', 2),
(83, 'B11', 2),
(84, 'B12', 2),
(85, 'B13', 2),
(86, 'B14', 2),
(87, 'B15', 2),
(137, 'B2', 1),
(12, 'B2', 2),
(179, 'B2', 3),
(138, 'B3', 1),
(13, 'B3', 2),
(180, 'B3', 3),
(139, 'B4', 1),
(14, 'B4', 2),
(181, 'B4', 3),
(140, 'B5', 1),
(15, 'B5', 2),
(182, 'B5', 3),
(141, 'B6', 1),
(78, 'B6', 2),
(183, 'B6', 3),
(142, 'B7', 1),
(79, 'B7', 2),
(184, 'B7', 3),
(143, 'B8', 1),
(80, 'B8', 2),
(185, 'B8', 3),
(81, 'B9', 2),
(144, 'C1', 1),
(110, 'C1', 2),
(16, 'C1', 3),
(91, 'C10', 3),
(92, 'C11', 3),
(93, 'C12', 3),
(94, 'C13', 3),
(95, 'C14', 3),
(96, 'C15', 3),
(145, 'C2', 1),
(111, 'C2', 2),
(17, 'C2', 3),
(146, 'C3', 1),
(112, 'C3', 2),
(18, 'C3', 3),
(147, 'C4', 1),
(113, 'C4', 2),
(19, 'C4', 3),
(148, 'C5', 1),
(114, 'C5', 2),
(20, 'C5', 3),
(149, 'C6', 1),
(115, 'C6', 2),
(76, 'C6', 3),
(150, 'C7', 1),
(116, 'C7', 2),
(88, 'C7', 3),
(151, 'C8', 1),
(117, 'C8', 2),
(89, 'C8', 3),
(90, 'C9', 3),
(152, 'D1', 1),
(118, 'D1', 2),
(186, 'D1', 3),
(153, 'D2', 1),
(119, 'D2', 2),
(187, 'D2', 3),
(154, 'D3', 1),
(120, 'D3', 2),
(188, 'D3', 3),
(155, 'D4', 1),
(121, 'D4', 2),
(189, 'D4', 3),
(156, 'D5', 1),
(122, 'D5', 2),
(190, 'D5', 3),
(157, 'D6', 1),
(123, 'D6', 2),
(191, 'D6', 3),
(158, 'D7', 1),
(124, 'D7', 2),
(192, 'D7', 3),
(159, 'D8', 1),
(125, 'D8', 2),
(193, 'D8', 3),
(160, 'E1', 1),
(126, 'E1', 2),
(194, 'E1', 3),
(169, 'E10', 1),
(135, 'E10', 2),
(203, 'E10', 3),
(161, 'E2', 1),
(127, 'E2', 2),
(195, 'E2', 3),
(162, 'E3', 1),
(128, 'E3', 2),
(196, 'E3', 3),
(163, 'E4', 1),
(129, 'E4', 2),
(197, 'E4', 3),
(164, 'E5', 1),
(130, 'E5', 2),
(198, 'E5', 3),
(165, 'E6', 1),
(131, 'E6', 2),
(199, 'E6', 3),
(166, 'E7', 1),
(132, 'E7', 2),
(200, 'E7', 3),
(167, 'E8', 1),
(133, 'E8', 2),
(201, 'E8', 3),
(168, 'E9', 1),
(134, 'E9', 2),
(202, 'E9', 3);

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_12_06_000001_add_payment_columns_to_transaksi_table', 2),
(5, '2025_12_07_000002_expand_status_enum_on_transaksi_table', 3),
(6, '2025_12_07_000003_alter_tanggal_transaksi_to_datetime', 4),
(7, '2025_12_07_000004_rename_payment_note_to_payment_account_name', 5),
(8, '2025_12_07_000005_drop_payment_reference_column', 6);

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('2q47c0oP6hvZZ8JP7CnIHeudVVPcL7xB1qBTgJKo', NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 13; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVERGR1NrNzNpWEJENHFpMG5jaHhHUkZsVTdGcDU2eGNzMVJUNmpObSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3N0ZXIvZG93bmxvYWQucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1764470414),
('BkpRaYPAVsbiiJh680aQGpVuMvzKMLgYqWWG9QDd', NULL, '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYk5zR1ZGWUNEUHVHeGZkVTl3cnpqUmIwZklYWnY3VHU0Z0VSVnp3SiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3N0ZXIvZG93bmxvYWQucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1764471090),
('gm5e5dW0smlm2wJPS7KnM6qabwRS1qdsgQIuwKSw', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTGUwaVA4VWtXYlA4aTJmekdxaVk2WERoNTBOSFE2NWN1NnoyejFqQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3N0ZXIvZG93bmxvYWQucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1764470940),
('l5JVkUv3l9XV2DDtMqxvgtnAevzRE8u4AMdzy6eY', NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 13; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaThZWEdBU250YmdZamxYd3FsamcwMEpGazVFSVNsQWNkcFNFOTlZaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3N0ZXIvZG93bmxvYWQucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1764468637),
('oIfNQJF7EwXEdnPsvlskUQfWVAHLed9d7nYb3dZd', NULL, '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMllDcGVtTVFNUDRDMkM1c0V3VGVtMDdXZWVZVGZmdDNSb3Y1RHJzWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wb3N0ZXIvZG93bmxvYWQucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1764471010);

-- --------------------------------------------------------

--
-- Struktur dari tabel `studio`
--

CREATE TABLE `studio` (
  `studio_id` int(11) NOT NULL,
  `nama_studio` varchar(50) NOT NULL,
  `tipe_studio` varchar(50) NOT NULL,
  `kapasitas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `studio`
--

INSERT INTO `studio` (`studio_id`, `nama_studio`, `tipe_studio`, `kapasitas`) VALUES
(1, 'Studio 1', 'Regular', 15),
(2, 'Studio 2', 'IMAX', 15),
(3, 'Studio 3', '3D', 15);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tiket`
--

CREATE TABLE `tiket` (
  `tiket_id` int(11) NOT NULL,
  `jadwal_id` int(11) DEFAULT NULL,
  `kursi_id` int(11) DEFAULT NULL,
  `harga` decimal(10,2) NOT NULL,
  `status` enum('tersedia','terjual') DEFAULT 'tersedia'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tiket`
--

INSERT INTO `tiket` (`tiket_id`, `jadwal_id`, `kursi_id`, `harga`, `status`) VALUES
(11, 2, 1, 55000.00, 'terjual'),
(12, 2, 2, 55000.00, 'terjual'),
(13, 2, 3, 55000.00, 'tersedia'),
(14, 2, 4, 55000.00, 'tersedia'),
(15, 2, 5, 55000.00, 'tersedia'),
(16, 2, 6, 55000.00, 'tersedia'),
(17, 2, 7, 55000.00, 'tersedia'),
(18, 2, 8, 55000.00, 'tersedia'),
(19, 2, 9, 50000.00, 'tersedia'),
(20, 2, 10, 50000.00, 'tersedia'),
(21, 3, 11, 65000.00, 'tersedia'),
(22, 3, 12, 65000.00, 'tersedia'),
(23, 3, 13, 65000.00, 'tersedia'),
(24, 3, 14, 65000.00, 'tersedia'),
(25, 3, 15, 65000.00, 'tersedia'),
(169, 3, 78, 65000.00, 'tersedia'),
(170, 3, 79, 65000.00, 'tersedia'),
(171, 3, 80, 65000.00, 'tersedia'),
(172, 3, 81, 100000.00, 'tersedia'),
(173, 3, 82, 100000.00, 'tersedia'),
(174, 3, 83, 100000.00, 'tersedia'),
(175, 3, 84, 100000.00, 'tersedia'),
(176, 3, 85, 100000.00, 'tersedia'),
(177, 3, 86, 100000.00, 'tersedia'),
(178, 3, 87, 100000.00, 'tersedia'),
(193, 2, 97, 50000.00, 'tersedia'),
(194, 2, 98, 50000.00, 'tersedia'),
(195, 2, 99, 50000.00, 'tersedia'),
(196, 2, 100, 50000.00, 'tersedia'),
(197, 2, 101, 50000.00, 'tersedia'),
(228, 13, 16, 75000.00, 'tersedia'),
(229, 13, 17, 75000.00, 'tersedia'),
(230, 13, 18, 75000.00, 'tersedia'),
(231, 13, 19, 75000.00, 'tersedia'),
(232, 13, 20, 75000.00, 'tersedia'),
(233, 13, 76, 75000.00, 'tersedia'),
(234, 13, 88, 75000.00, 'tersedia'),
(235, 13, 89, 75000.00, 'tersedia'),
(236, 13, 90, 75000.00, 'tersedia'),
(237, 13, 91, 75000.00, 'tersedia'),
(238, 13, 92, 75000.00, 'tersedia'),
(239, 13, 93, 75000.00, 'tersedia'),
(240, 13, 94, 75000.00, 'tersedia'),
(241, 13, 95, 75000.00, 'tersedia'),
(242, 13, 96, 75000.00, 'tersedia'),
(243, 14, 11, 70000.00, 'tersedia'),
(244, 14, 12, 70000.00, 'tersedia'),
(245, 14, 13, 70000.00, 'tersedia'),
(246, 14, 14, 70000.00, 'tersedia'),
(247, 14, 15, 70000.00, 'tersedia'),
(248, 14, 78, 70000.00, 'tersedia'),
(249, 14, 79, 70000.00, 'tersedia'),
(250, 14, 80, 70000.00, 'tersedia'),
(251, 14, 81, 100000.00, 'tersedia'),
(252, 14, 82, 100000.00, 'tersedia'),
(253, 14, 83, 100000.00, 'tersedia'),
(254, 14, 84, 100000.00, 'tersedia'),
(255, 14, 85, 100000.00, 'tersedia'),
(256, 14, 86, 100000.00, 'tersedia'),
(257, 14, 87, 100000.00, 'tersedia'),
(258, 16, 11, 60000.00, 'terjual'),
(259, 16, 12, 60000.00, 'terjual'),
(260, 16, 13, 60000.00, 'terjual'),
(261, 16, 14, 60000.00, 'terjual'),
(262, 16, 15, 60000.00, 'terjual'),
(263, 16, 78, 60000.00, 'terjual'),
(264, 16, 79, 60000.00, 'terjual'),
(265, 16, 80, 60000.00, 'terjual'),
(266, 16, 81, 100000.00, 'tersedia'),
(267, 16, 82, 100000.00, 'tersedia'),
(268, 16, 83, 100000.00, 'tersedia'),
(269, 16, 84, 100000.00, 'tersedia'),
(270, 16, 85, 100000.00, 'tersedia'),
(271, 16, 86, 100000.00, 'tersedia'),
(272, 16, 87, 100000.00, 'tersedia'),
(273, 16, 102, 60000.00, 'tersedia'),
(274, 16, 103, 60000.00, 'tersedia'),
(275, 16, 104, 60000.00, 'tersedia'),
(276, 16, 105, 60000.00, 'tersedia'),
(277, 16, 106, 60000.00, 'tersedia'),
(278, 16, 107, 60000.00, 'tersedia'),
(279, 16, 108, 60000.00, 'tersedia'),
(280, 16, 109, 60000.00, 'tersedia'),
(281, 16, 110, 60000.00, 'tersedia'),
(282, 16, 111, 60000.00, 'tersedia'),
(283, 16, 112, 60000.00, 'tersedia'),
(284, 16, 113, 60000.00, 'tersedia'),
(285, 16, 114, 60000.00, 'tersedia'),
(286, 16, 115, 60000.00, 'tersedia'),
(287, 16, 116, 60000.00, 'tersedia'),
(288, 16, 117, 60000.00, 'tersedia'),
(289, 16, 118, 60000.00, 'tersedia'),
(290, 16, 119, 60000.00, 'tersedia'),
(291, 16, 120, 60000.00, 'tersedia'),
(292, 16, 121, 60000.00, 'tersedia'),
(293, 16, 122, 60000.00, 'tersedia'),
(294, 16, 123, 60000.00, 'tersedia'),
(295, 16, 124, 60000.00, 'tersedia'),
(296, 16, 125, 60000.00, 'tersedia'),
(297, 16, 126, 60000.00, 'tersedia'),
(298, 16, 127, 60000.00, 'tersedia'),
(299, 16, 128, 60000.00, 'tersedia'),
(300, 16, 129, 60000.00, 'tersedia'),
(301, 16, 130, 60000.00, 'tersedia'),
(302, 16, 131, 60000.00, 'tersedia'),
(303, 16, 132, 60000.00, 'tersedia'),
(304, 16, 133, 60000.00, 'tersedia'),
(305, 16, 134, 60000.00, 'tersedia'),
(306, 16, 135, 60000.00, 'tersedia'),
(391, 13, 170, 75000.00, 'terjual'),
(392, 13, 171, 75000.00, 'terjual'),
(393, 13, 172, 75000.00, 'terjual'),
(394, 13, 173, 75000.00, 'terjual'),
(395, 13, 174, 75000.00, 'tersedia'),
(396, 13, 175, 75000.00, 'tersedia'),
(397, 13, 176, 75000.00, 'tersedia'),
(398, 13, 177, 75000.00, 'tersedia'),
(399, 13, 178, 75000.00, 'tersedia'),
(400, 13, 179, 75000.00, 'tersedia'),
(401, 13, 180, 75000.00, 'tersedia'),
(402, 13, 181, 75000.00, 'tersedia'),
(403, 13, 182, 75000.00, 'tersedia'),
(404, 13, 183, 75000.00, 'tersedia'),
(405, 13, 184, 75000.00, 'tersedia'),
(406, 13, 185, 75000.00, 'tersedia'),
(407, 13, 186, 75000.00, 'tersedia'),
(408, 13, 187, 75000.00, 'tersedia'),
(409, 13, 188, 75000.00, 'tersedia'),
(410, 13, 189, 75000.00, 'tersedia'),
(411, 13, 190, 75000.00, 'tersedia'),
(412, 13, 191, 75000.00, 'tersedia'),
(413, 13, 192, 75000.00, 'tersedia'),
(414, 13, 193, 75000.00, 'tersedia'),
(415, 13, 194, 75000.00, 'tersedia'),
(416, 13, 195, 75000.00, 'tersedia'),
(417, 13, 196, 75000.00, 'tersedia'),
(418, 13, 197, 75000.00, 'tersedia'),
(419, 13, 198, 75000.00, 'tersedia'),
(420, 13, 199, 75000.00, 'tersedia'),
(421, 13, 200, 75000.00, 'tersedia'),
(422, 13, 201, 75000.00, 'tersedia'),
(423, 13, 202, 75000.00, 'tersedia'),
(424, 13, 203, 75000.00, 'tersedia'),
(425, 3, 102, 65000.00, 'terjual'),
(426, 3, 103, 65000.00, 'terjual'),
(427, 3, 104, 65000.00, 'tersedia'),
(428, 3, 105, 65000.00, 'tersedia'),
(429, 3, 106, 65000.00, 'tersedia'),
(430, 3, 107, 65000.00, 'tersedia'),
(431, 3, 108, 65000.00, 'tersedia'),
(432, 3, 109, 65000.00, 'tersedia'),
(433, 3, 110, 65000.00, 'tersedia'),
(434, 3, 111, 65000.00, 'tersedia'),
(435, 3, 112, 65000.00, 'tersedia'),
(436, 3, 113, 65000.00, 'tersedia'),
(437, 3, 114, 65000.00, 'tersedia'),
(438, 3, 115, 65000.00, 'tersedia'),
(439, 3, 116, 65000.00, 'tersedia'),
(440, 3, 117, 65000.00, 'tersedia'),
(441, 3, 118, 65000.00, 'tersedia'),
(442, 3, 119, 65000.00, 'tersedia'),
(443, 3, 120, 65000.00, 'tersedia'),
(444, 3, 121, 65000.00, 'tersedia'),
(445, 3, 122, 65000.00, 'tersedia'),
(446, 3, 123, 65000.00, 'tersedia'),
(447, 3, 124, 65000.00, 'tersedia'),
(448, 3, 125, 65000.00, 'tersedia'),
(449, 3, 126, 65000.00, 'tersedia'),
(450, 3, 127, 65000.00, 'tersedia'),
(451, 3, 128, 65000.00, 'tersedia'),
(452, 3, 129, 65000.00, 'tersedia'),
(453, 3, 130, 65000.00, 'tersedia'),
(454, 3, 131, 65000.00, 'tersedia'),
(455, 3, 132, 65000.00, 'tersedia'),
(456, 3, 133, 65000.00, 'tersedia'),
(457, 3, 134, 65000.00, 'tersedia'),
(458, 3, 135, 65000.00, 'tersedia'),
(459, 14, 102, 70000.00, 'terjual'),
(460, 14, 103, 70000.00, 'terjual'),
(461, 14, 104, 70000.00, 'terjual'),
(462, 14, 105, 70000.00, 'tersedia'),
(463, 14, 106, 70000.00, 'tersedia'),
(464, 14, 107, 70000.00, 'tersedia'),
(465, 14, 108, 70000.00, 'tersedia'),
(466, 14, 109, 70000.00, 'tersedia'),
(467, 14, 110, 70000.00, 'tersedia'),
(468, 14, 111, 70000.00, 'tersedia'),
(469, 14, 112, 70000.00, 'tersedia'),
(470, 14, 113, 70000.00, 'tersedia'),
(471, 14, 114, 70000.00, 'tersedia'),
(472, 14, 115, 70000.00, 'tersedia'),
(473, 14, 116, 70000.00, 'tersedia'),
(474, 14, 117, 70000.00, 'tersedia'),
(475, 14, 118, 70000.00, 'tersedia'),
(476, 14, 119, 70000.00, 'tersedia'),
(477, 14, 120, 70000.00, 'tersedia'),
(478, 14, 121, 70000.00, 'tersedia'),
(479, 14, 122, 70000.00, 'tersedia'),
(480, 14, 123, 70000.00, 'tersedia'),
(481, 14, 124, 70000.00, 'tersedia'),
(482, 14, 125, 70000.00, 'tersedia'),
(483, 14, 126, 70000.00, 'tersedia'),
(484, 14, 127, 70000.00, 'tersedia'),
(485, 14, 128, 70000.00, 'tersedia'),
(486, 14, 129, 70000.00, 'tersedia'),
(487, 14, 130, 70000.00, 'tersedia'),
(488, 14, 131, 70000.00, 'tersedia'),
(489, 14, 132, 70000.00, 'tersedia'),
(490, 14, 133, 70000.00, 'tersedia'),
(491, 14, 134, 70000.00, 'tersedia'),
(492, 14, 135, 70000.00, 'tersedia'),
(493, 2, 136, 55000.00, 'tersedia'),
(494, 2, 137, 55000.00, 'tersedia'),
(495, 2, 138, 55000.00, 'tersedia'),
(496, 2, 139, 55000.00, 'tersedia'),
(497, 2, 140, 55000.00, 'tersedia'),
(498, 2, 141, 55000.00, 'tersedia'),
(499, 2, 142, 55000.00, 'tersedia'),
(500, 2, 143, 55000.00, 'tersedia'),
(501, 2, 144, 55000.00, 'tersedia'),
(502, 2, 145, 55000.00, 'tersedia'),
(503, 2, 146, 55000.00, 'tersedia'),
(504, 2, 147, 55000.00, 'tersedia'),
(505, 2, 148, 55000.00, 'tersedia'),
(506, 2, 149, 55000.00, 'tersedia'),
(507, 2, 150, 55000.00, 'tersedia'),
(508, 2, 151, 55000.00, 'tersedia'),
(509, 2, 152, 55000.00, 'tersedia'),
(510, 2, 153, 55000.00, 'tersedia'),
(511, 2, 154, 55000.00, 'tersedia'),
(512, 2, 155, 55000.00, 'tersedia'),
(513, 2, 156, 55000.00, 'tersedia'),
(514, 2, 157, 55000.00, 'tersedia'),
(515, 2, 158, 55000.00, 'tersedia'),
(516, 2, 159, 55000.00, 'tersedia'),
(517, 2, 160, 55000.00, 'tersedia'),
(518, 2, 161, 55000.00, 'tersedia'),
(519, 2, 162, 55000.00, 'tersedia'),
(520, 2, 163, 55000.00, 'tersedia'),
(521, 2, 164, 55000.00, 'tersedia'),
(522, 2, 165, 55000.00, 'tersedia'),
(523, 2, 166, 55000.00, 'tersedia'),
(524, 2, 167, 55000.00, 'tersedia'),
(525, 2, 168, 55000.00, 'tersedia'),
(526, 2, 169, 55000.00, 'tersedia');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `kasir_id` int(11) DEFAULT NULL,
  `tanggal_transaksi` datetime DEFAULT NULL,
  `total_harga` decimal(12,2) NOT NULL,
  `status` enum('pending','sukses','batal') NOT NULL DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_destination` varchar(120) DEFAULT NULL,
  `payment_account_name` varchar(150) DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transaksi`
--

INSERT INTO `transaksi` (`transaksi_id`, `customer_id`, `kasir_id`, `tanggal_transaksi`, `total_harga`, `status`, `payment_method`, `payment_destination`, `payment_account_name`, `paid_at`) VALUES
(64, 11, 1, '2025-11-11 00:00:00', 100000.00, 'sukses', NULL, NULL, NULL, NULL),
(65, 11, 1, '2025-11-11 00:00:00', 100000.00, 'sukses', NULL, NULL, NULL, NULL),
(66, 12, 1, '2025-11-11 00:00:00', 100000.00, 'sukses', NULL, NULL, NULL, NULL),
(67, 11, 1, '2025-11-30 00:00:00', 65000.00, 'sukses', NULL, NULL, NULL, NULL),
(75, 13, 1, '2025-12-07 00:17:18', 75000.00, 'sukses', 'QRIS', 'ID1023241444042', 'Amarrazan Yuka', '2025-12-06 17:17:18'),
(76, 13, 1, '2025-12-07 00:42:25', 65000.00, 'sukses', 'BRI', '033401001122334', 'Amarrazan Yuka', '2025-12-06 17:44:35'),
(77, 12, 1, '2025-12-07 01:39:33', 150000.00, 'sukses', 'QRIS', 'ID1023241444042', 'Dilla Ayu', '2025-12-06 21:07:49');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id_users` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','customer') NOT NULL DEFAULT 'customer',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id_users`, `name`, `username`, `password`, `role`, `created_at`, `updated_at`) VALUES
(1, 'Administrator', 'admin', '$2y$12$YKId4tSpJuzk8p5uMycgE.mwLbsmxLCp/T7BskyuV2YXTnYxvBKJW', 'admin', '2025-10-31 02:00:00', '2025-10-31 02:00:00'),
(5, 'Brian Evan', 'brian', '$2y$12$QKp3o6BFF1k70WO4XbmRlOzqPG6Jy00xr8E7kh2c4WBOMhiM6TUh.', 'customer', '2025-11-10 22:50:28', '2025-11-30 03:35:19'),
(6, 'Dilla Ayu', 'dilla', '$2y$12$4H2LwY5PvZDM.dIhVMpY.eJ98AlufRlMnmS4p0.HKNq3/MOZRcKv.', 'customer', '2025-11-10 23:42:54', '2025-11-30 02:20:45'),
(7, 'Amarrazan Yuka', 'amarrazan', '$2y$12$VvNSd/TJNGyvxkcDdjoRYuc4UqSYinMBLTB85lqdGTejo4QnidR1a', 'customer', '2025-12-06 08:32:18', '2025-12-06 08:32:18');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`detail_id`),
  ADD UNIQUE KEY `transaksi_id` (`transaksi_id`,`tiket_id`),
  ADD KEY `fk_detail_tiket` (`tiket_id`),
  ADD KEY `film_id` (`film_id`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indeks untuk tabel `film`
--
ALTER TABLE `film`
  ADD PRIMARY KEY (`film_id`),
  ADD KEY `fk_film_genre` (`genre_id`);

--
-- Indeks untuk tabel `genre`
--
ALTER TABLE `genre`
  ADD PRIMARY KEY (`genre_id`);

--
-- Indeks untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  ADD PRIMARY KEY (`jadwal_id`),
  ADD KEY `fk_jadwal_film` (`film_id`),
  ADD KEY `fk_jadwal_studio` (`studio_id`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `kasir`
--
ALTER TABLE `kasir`
  ADD PRIMARY KEY (`kasir_id`);

--
-- Indeks untuk tabel `komentar`
--
ALTER TABLE `komentar`
  ADD PRIMARY KEY (`komentar_id`),
  ADD KEY `fk_komentar_customer` (`users_id`),
  ADD KEY `fk_komentar_film` (`film_id`);

--
-- Indeks untuk tabel `kursi`
--
ALTER TABLE `kursi`
  ADD PRIMARY KEY (`kursi_id`),
  ADD UNIQUE KEY `nomor_kursi` (`nomor_kursi`,`studio_id`),
  ADD KEY `fk_kursi_studio` (`studio_id`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indeks untuk tabel `studio`
--
ALTER TABLE `studio`
  ADD PRIMARY KEY (`studio_id`);

--
-- Indeks untuk tabel `tiket`
--
ALTER TABLE `tiket`
  ADD PRIMARY KEY (`tiket_id`),
  ADD UNIQUE KEY `jadwal_id` (`jadwal_id`,`kursi_id`),
  ADD KEY `fk_tiket_kursi` (`kursi_id`);

--
-- Indeks untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `fk_transaksi_customer` (`customer_id`),
  ADD KEY `fk_transaksi_kasir` (`kasir_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_users`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `film`
--
ALTER TABLE `film`
  MODIFY `film_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT untuk tabel `genre`
--
ALTER TABLE `genre`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  MODIFY `jadwal_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kasir`
--
ALTER TABLE `kasir`
  MODIFY `kasir_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `komentar`
--
ALTER TABLE `komentar`
  MODIFY `komentar_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT untuk tabel `kursi`
--
ALTER TABLE `kursi`
  MODIFY `kursi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `studio`
--
ALTER TABLE `studio`
  MODIFY `studio_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `tiket`
--
ALTER TABLE `tiket`
  MODIFY `tiket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=527;

--
-- AUTO_INCREMENT untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id_users` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_ibfk_1` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`),
  ADD CONSTRAINT `fk_detail_tiket` FOREIGN KEY (`tiket_id`) REFERENCES `tiket` (`tiket_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_detail_transaksi` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `film`
--
ALTER TABLE `film`
  ADD CONSTRAINT `fk_film_genre` FOREIGN KEY (`genre_id`) REFERENCES `genre` (`genre_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `jadwal`
--
ALTER TABLE `jadwal`
  ADD CONSTRAINT `fk_jadwal_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_jadwal_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `komentar`
--
ALTER TABLE `komentar`
  ADD CONSTRAINT `fk_komentar_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `kursi`
--
ALTER TABLE `kursi`
  ADD CONSTRAINT `fk_kursi_studio` FOREIGN KEY (`studio_id`) REFERENCES `studio` (`studio_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tiket`
--
ALTER TABLE `tiket`
  ADD CONSTRAINT `fk_tiket_jadwal` FOREIGN KEY (`jadwal_id`) REFERENCES `jadwal` (`jadwal_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tiket_kursi` FOREIGN KEY (`kursi_id`) REFERENCES `kursi` (`kursi_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `fk_transaksi_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaksi_kasir` FOREIGN KEY (`kasir_id`) REFERENCES `kasir` (`kasir_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
