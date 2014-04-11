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

	unit_suspended BOOLEAN NOT NULL DEFAULT 'no',
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
	holder_suspended BOOLEAN NOT NULL,

	holder_photo    BYTEA NOT NULL,

	UNIQUE(holder_name, family_num)
);

CREATE TABLE passholder_phones (
	passholder_num  INTEGER NOT NULL REFERENCES passholders ON DELETE CASCADE,
	phone_label    VARCHAR(20) NOT NULL,
	phone_number   VARCHAR(20) NOT NULL
);

CREATE TABLE passes (
	-- pass numbers are generated randomly, to avoid trickery
	pass_num        INTEGER NOT NULL PRIMARY KEY,

	passholder_num  INTEGER NULL REFERENCES passholders ON DELETE SET NULL,
	pass_issued    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	pass_valid     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE contacts (
	contact_num     SERIAL PRIMARY KEY,
	family_num      INTEGER NOT NULL REFERENCES families ON DELETE CASCADE,
	contact_name   VARCHAR(100) NOT NULL,
	contact_notes  TEXT
);

CREATE TABLE contact_phones (
	contact_num     INTEGER NOT NULL REFERENCES contacts ON DELETE CASCADE,
	phone_number   VARCHAR(20) NOT NULL,
	phone_label    VARCHAR(20) NOT NULL,
	PRIMARY KEY (contact_num, phone_number)
);

CREATE TABLE passholder_contacts (
	passholder_num  INTEGER NOT NULL REFERENCES passholders ON DELETE CASCADE,
	contact_num     INTEGER NOT NULL REFERENCES contacts ON DELETE CASCADE,
	contact_order  INTEGER NOT NULL,
	PRIMARY KEY (passholder_num, contact_num)
);
