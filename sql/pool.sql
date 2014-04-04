CREATE TABLE streets (
	street_name   VARCHAR(100) NOT NULL PRIMARY KEY
);

CREATE TABLE street_aliases (
	street_alias  VARCHAR(100) NOT NULL PRIMARY KEY,
	street_name   VARCHAR(100) NOT NULL REFERENCES streets
);

CREATE TABLE units (
	unit_no        INTEGER NOT NULL PRIMARY KEY,
	street_no      INTEGER NOT NULL,
	street_name    VARCHAR(100) NOT NULL REFERENCES streets,

	unit_suspended BOOLEAN NOT NULL DEFAULT 'no',
	UNIQUE(street_no, street_name)
);

CREATE TABLE families (
	family_no      SERIAL NOT NULL PRIMARY KEY,
	unit_no        INTEGER NOT NULL REFERENCES units,
	family_name    VARCHAR(30) NOT NULL,
	UNIQUE(unit_no, family_name)
);

CREATE TABLE age_ranges (
	age_range      VARCHAR(20) NOT NULL PRIMARY KEY
);

CREATE TABLE passholders (
	-- passholder number is not printed on the pass
	passholder_no  SERIAL NOT NULL PRIMARY KEY,
	family_no      INTEGER NOT NULL REFERENCES families ON DELETE CASCADE,

	holder_name      VARCHAR(100) NOT NULL,
	holder_dob       DATE NOT NULL,
	holder_can_swim  BOOLEAN NOT NULL,
	holder_suspended BOOLEAN NOT NULL,

	UNIQUE(holder_name, family_no)
);

CREATE TABLE passholder_phones (
	passholder_no  INTEGER NOT NULL REFERENCES passholders ON DELETE CASCADE,
	phone_label    VARCHAR(20) NOT NULL,
	phone_number   VARCHAR(20) NOT NULL
);

CREATE TABLE passes (
	-- pass numbers are generated randomly, to avoid trickery
	pass_no        INTEGER NOT NULL PRIMARY KEY,

	passholder_no  INTEGER NOT NULL REFERENCES passholders ON DELETE SET NULL,
	pass_issued    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	pass_valid     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE contacts (
	contact_no     SERIAL PRIMARY KEY,
	family_no      INTEGER NOT NULL REFERENCES families ON DELETE CASCADE,
	contact_name   VARCHAR(100) NOT NULL,
	contact_notes  TEXT
);

CREATE TABLE contact_phones (
	contact_no     INTEGER NOT NULL REFERENCES contacts ON DELETE CASCADE,
	phone_number   VARCHAR(20) NOT NULL,
	phone_label    VARCHAR(20) NOT NULL,
	PRIMARY KEY (contact_no, phone_number)
);

CREATE TABLE passholder_contacts (
	passholder_no  INTEGER NOT NULL REFERENCES passholders ON DELETE CASCADE,
	contact_no     INTEGER NOT NULL REFERENCES contacts ON DELETE CASCADE,
	contact_order  INTEGER NOT NULL,
	PRIMARY KEY (passholder_no, contact_no)
);
