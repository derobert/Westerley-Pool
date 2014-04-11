-- WARNING: This file is intended to be run against an empty database.
--          Weird things may happen if there is already data (e.g.,
--          because the queries matched existing data in addition to the
--          sample data).
--
-- Further, note that many of these queries aren't indexed... Its not
-- expected that the app will be looking up things this way...

-- Load some variables with many-KB binary strings
\i photo-vars.sql

INSERT INTO streets (street_name) VALUES
	('Sample Street'),
	('Example Lane');

INSERT INTO street_aliases (street_alias, street_name) VALUES
	('Sample St', 'Sample Street'),
	('Example Ln', 'Example Lane');

INSERT INTO units (unit_num, house_number, street_name) VALUES
	(1, 100, 'Sample Street'),
	(2, 101, 'Sample Street'),
	(3, 100, 'Example Lane');

INSERT INTO families (unit_num, family_name) VALUES
	(1, 'Smith'),
	(2, 'Doe');

INSERT INTO contacts (family_num, contact_name) VALUES
	((SELECT family_num FROM families WHERE family_name = 'Smith'), 'Contact 1'),
	((SELECT family_num FROM families WHERE family_name = 'Smith'), 'Contact 2');

INSERT INTO passholders (
	family_num, holder_name, holder_dob, holder_can_swim, holder_suspended,
	holder_photo
) VALUES
	(
		(SELECT family_num FROM families WHERE family_name = 'Smith'),
		'John Smith', '1900-01-01', TRUE, FALSE,
		DECODE(:'john_smith_jpeg', 'hex')
	), (
		(SELECT family_num FROM families WHERE family_name = 'Smith'),
		'John Smith, Jr.', '2000-01-01', TRUE, FALSE,
		DECODE(:'john_smith_jr_jpeg', 'hex')
	), (
		(SELECT family_num FROM families WHERE family_name = 'Doe'),
		'Joe Doe', '1900-01-01', TRUE, FALSE,
		DECODE(:'joe_doe_jpeg', 'hex')
	);

INSERT INTO contact_phones (contact_num, phone_number, phone_label)
VALUES 
	(
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 1'),
		'(703) 555-5555', 'Home'
	), (
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 1'),
		'(571) 555-5555', 'Work'
	), (
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 1'),
		'(202) 555-5555', 'Cell'
	);

INSERT INTO passholder_contacts (passholder_num, contact_num, contact_order)
VALUEs
	(
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith'),
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 1'),
		10
	), (
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith, Jr.'),
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 2'),
		10
	), (
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith, Jr.'),
		(SELECT contact_num FROM contacts WHERE contact_name = 'Contact 1'),
		20
	);

INSERT INTO passes (passholder_num, pass_num, pass_issued, pass_valid) VALUES
	(
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith'),
		1119887944, '2014-04-01 16:00:00-0400', TRUE
	), (
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith'),
		266956807, '2014-04-01 15:00:00-0400', FALSE
	), (
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith, Jr.'),
		1308019131, '2014-04-01 15:30:00-0400', FALSE
	), (
		NULL, 778420100, '1980-01-02 12:00:00-0500', FALSE
	);
	
INSERT INTO passholder_phones (passholder_num, phone_label, phone_number) VALUES
	(
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith'),
		'Cell', '(301) 555-5555'
	), (
		(SELECT passholder_num FROM passholders WHERE holder_name='John Smith'),
		'Home', '(701) 555-5555'
	);

\i photo-unvars.sql
