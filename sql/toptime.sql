CREATE TABLE IF NOT EXISTS `users_playtime` (
  `steam` varchar(50) NOT NULL,
  `steam_name` longtext NOT NULL,
  `game_name` longtext NOT NULL,
  `total_time` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
