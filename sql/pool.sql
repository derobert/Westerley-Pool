CREATE DOMAIN rgb_color_value AS real
  CONSTRAINT color_value_range
  NOT NULL
  CHECK (VALUE >= 0 AND VALUE <= 1);

CREATE TYPE rgb_color AS (
	red            rgb_color_value,
	green          rgb_color_value,
	blue           rgb_color_value
);

CREATE TABLE age_groups (
	age_group_num  SERIAL NOT NULL PRIMARY KEY,
	age_group_name VARCHAR(100) NOT NULL UNIQUE,
	age_group_color rgb_color NOT NULL,
	min_age        INTERVAL YEAR TO MONTH NOT NULL UNIQUE, -- ≥ (gte)
	max_age        INTERVAL YEAR TO MONTH NOT NULL UNIQUE  -- < (lt)
	-- NOTE: PostgreSQL supports intervals up to 178000000 years,
	-- according to the docs. Use an arbitrarily large max_age for your
	-- last range.
	
	-- WARNING: There is a requirement that all possible ages are in
	-- one and only one range. This would seem to require a CHECK
	-- constraint with a subquery, and unfortunately PostgreSQL does not
	-- support that. You must enforce this when you put your data in.
);

CREATE OR REPLACE FUNCTION datediff_ym (IN d1 DATE, IN d2 DATE)
  RETURNS INTERVAL YEAR TO MONTH
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT
  SECURITY INVOKER
  AS $$
	SELECT
	  (EXTRACT(YEAR FROM d1)-EXTRACT(YEAR FROM d2))*(INTERVAL '1' YEAR) 
	+ (EXTRACT(MONTH FROM d1)-EXTRACT(MONTH FROM d2))*(INTERVAL '1' MONTH)
  $$;

CREATE TABLE streets (
	street_ref    SERIAL NOT NULL PRIMARY KEY,
	street_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE street_aliases (
	street_alias  VARCHAR(100) NOT NULL PRIMARY KEY,
	street_ref    INTEGER NOT NULL REFERENCES streets
);

CREATE TABLE units (
	unit_num       INTEGER NOT NULL PRIMARY KEY,
	house_number   INTEGER NOT NULL,
	street_ref     INTEGER NULL REFERENCES streets,

	unit_suspended BOOLEAN NOT NULL DEFAULT false,
	UNIQUE(house_number, street_ref)
);

CREATE TABLE families (
	family_num      SERIAL NOT NULL PRIMARY KEY,
	unit_num        INTEGER NOT NULL REFERENCES units,
	family_name    VARCHAR(30) NOT NULL,
	UNIQUE(unit_num, family_name)
);

CREATE TABLE passholders (
	-- passholder number is not printed on the pass
	passholder_num  SERIAL NOT NULL PRIMARY KEY,
	family_num      INTEGER NOT NULL REFERENCES families ON DELETE CASCADE,

	holder_name      VARCHAR(100) NOT NULL,
	holder_dob       DATE NOT NULL,
	holder_can_swim  BOOLEAN NOT NULL,
	holder_suspended BOOLEAN NOT NULL DEFAULT false,

	holder_notes    TEXT NOT NULL DEFAULT '',
	holder_photo    BYTEA NULL,

	UNIQUE(holder_name, family_num)
);

CREATE TABLE passes (
	-- pass numbers are generated randomly, to avoid trickery
	pass_num        INTEGER NOT NULL PRIMARY KEY,

	passholder_num  INTEGER NULL REFERENCES passholders ON DELETE SET NULL,
	pass_issued     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	pass_printed    TIMESTAMP WITH TIME ZONE NULL DEFAULT NULL,
	pass_valid      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE contacts (
	contact_num       SERIAL PRIMARY KEY,
	family_num        INTEGER NOT NULL REFERENCES families ON DELETE CASCADE,
	contact_order     INTEGER NOT NULL,
	contact_name      VARCHAR(100) NOT NULL,
	contact_admin     BOOLEAN NOT NULL,
	contact_emergency BOOLEAN NOT NULL,
	contact_notes     TEXT,
	UNIQUE(family_num, contact_order)
);

CREATE TABLE contact_phones (
	contact_num     INTEGER NOT NULL REFERENCES contacts ON DELETE CASCADE,
	phone_number   VARCHAR(20) NOT NULL,
	phone_label    VARCHAR(20) NOT NULL,
	PRIMARY KEY (contact_num, phone_number)
);

CREATE TABLE users (
	user_num      SERIAL PRIMARY KEY,
	user_name     VARCHAR(50) UNIQUE,
	user_pwhash   VARCHAR(200) NOT NULL,
	user_active   BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE roles (
	role_num      SERIAL PRIMARY KEY, -- silly, but consistent
	role_name     VARCHAR(50) UNIQUE,
	role_descr    TEXT NOT NULL
);

INSERT INTO roles (role_name, role_descr) VALUES
	( 'admin', 'Access the administrative interface' ),
	( 'backup', 'Perform data backups' )
	;

CREATE TABLE user_roles (
	user_num      INTEGER NOT NULL REFERENCES users ON DELETE CASCADE,
	role_num      INTEGER NOT NULL REFERENCES roles ON DELETE CASCADE,
	PRIMARY KEY(user_num, role_num)
);

CREATE UNLOGGED TABLE sessions (
	session_id        CHAR(72) PRIMARY KEY,
	session_data      TEXT,
	session_expires   INTEGER
);

CREATE TYPE log_entry_type AS ENUM (
	'view',     -- pass viewed (e.g., scanned with barcode scanner)
	'checkin',  -- guard pressed checkin button
	'checkout'  -- guard pressed checkout button (future)
);

CREATE TABLE log (
	log_num        SERIAL PRIMARY KEY,
	log_time       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	log_type       LOG_ENTRY_TYPE NOT NULL,
	pass_num       INTEGER NOT NULL REFERENCES passes ON DELETE NO ACTION,
	holder_name    VARCHAR(100) NOT NULL DEFAULT 'N/A',
	family_name    VARCHAR(30) NOT NULL DEFAULT 'N/A',
	house_number   INTEGER NOT NULL DEFAULT -1,
	street_name    VARCHAR(100) NOT NULL DEFAULT 'N/A'
);
