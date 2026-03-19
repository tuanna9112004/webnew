-- SePay smooth integration settings
CREATE TABLE IF NOT EXISTS app_settings (
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO app_settings (setting_key, setting_value, updated_at) VALUES
('sepay_bank_name', 'MB Bank', NOW()),
('sepay_bank_code', 'MBBank', NOW()),
('sepay_bank_account_no', '', NOW()),
('sepay_account_name', '', NOW()),
('sepay_webhook_api_key', '', NOW()),
('sepay_expected_sub_account', '', NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();
