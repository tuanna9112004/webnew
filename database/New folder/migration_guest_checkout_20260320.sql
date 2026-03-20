ALTER TABLE orders
  ADD COLUMN request_id VARCHAR(64) NULL AFTER guest_access_token,
  ADD UNIQUE KEY uq_orders_request_id (request_id);
