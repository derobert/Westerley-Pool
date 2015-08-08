ALTER TYPE log_entry_type ADD VALUE IF NOT EXISTS
  'checkin_scanned' AFTER 'checkout';
ALTER TYPE log_entry_type ADD VALUE IF NOT EXISTS
  'checkin_search' AFTER 'checkin_scanned';
