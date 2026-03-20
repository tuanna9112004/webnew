-- Tu chon: import file nay neu muon tao bang log thong bao truoc
CREATE TABLE IF NOT EXISTS `telegram_notification_logs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int(10) unsigned NOT NULL,
  `event_key` varchar(64) NOT NULL,
  `chat_id` varchar(64) NOT NULL,
  `message_text` text DEFAULT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_telegram_order_event_chat` (`order_id`,`event_key`,`chat_id`),
  KEY `idx_telegram_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `app_settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('telegram_bot_username', '', NOW()),
('telegram_bot_token', '', NOW()),
('telegram_chat_id', '', NOW()),
('telegram_notify_enabled', '0', NOW())
ON DUPLICATE KEY UPDATE
`setting_value` = VALUES(`setting_value`),
`updated_at` = NOW();
