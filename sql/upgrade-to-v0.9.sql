ALTER TABLE log ADD COLUMN
  log_guests     SMALLINT CHECK (log_guests >= 0);
