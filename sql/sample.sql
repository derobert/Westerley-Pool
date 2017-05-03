-- WARNING: This file is intended to be run against an empty database.
--          Weird things may happen if there is already data (e.g.,
--          because the queries matched existing data in addition to the
--          sample data).
--
-- Further, note that many of these queries aren't indexed... Its not
-- expected that the app will be looking up things this way...

-- Load some variables with many-KB binary strings
\i photo-vars.sql

INSERT INTO age_groups(age_group_name,age_group_color, min_age, max_age) VALUES 
	('Under 12', '(1.0, 0.5, 0.5)', '0-0',  '12-0'),
	('12–15',    '(0.5, 0.5, 1.0)', '12-0', '16-0'),
	('16–17',    '(0.5, 0.5, 1.0)', '16-0', '18-0'),
	('Adult',    '(0.5, 1.0, 0.5)', '18-0', '9999-11');

INSERT INTO streets (street_name) VALUES
	('Sample Street'),
	('Example Lane');

INSERT INTO street_aliases (street_alias, street_ref) VALUES
	('Sample St', (SELECT street_ref FROM streets WHERE street_name='Sample Street')),
	('Example Ln', (SELECT street_ref FROM streets WHERE street_name='Example Lane'));

INSERT INTO units (unit_num, house_number, street_ref) VALUES
	(1, 100, (SELECT street_ref FROM streets WHERE street_name='Sample Street')),
	(2, 101, (SELECT street_ref FROM streets WHERE street_name='Sample Street')),
	(3, 100, (SELECT street_ref FROM streets WHERE street_name='Example Lane'));

INSERT INTO families (unit_num, family_name) VALUES
	(1, 'Smith'),
	(2, 'Doe');

INSERT INTO contacts (
	family_num, contact_name, contact_order, contact_admin, contact_emergency
) VALUES
	(
		(SELECT family_num FROM families WHERE family_name = 'Smith'), 
		'Contact 1', 10, true, false
	), (
		(SELECT family_num FROM families WHERE family_name = 'Smith'), 
		'Contact 2', 20, true, true
	);

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

INSERT INTO documents (document_name, passholder_min_age, passholder_max_age) VALUES
	( 'Pool Rules', '16-0', '9999-11' );
INSERT INTO document_versions (document_num, version_date) VALUES
	(
		(SELECT document_num FROM documents WHERE document_name = 'Pool Rules'),
		'2017-05-01'
	);
	
\i photo-unvars.sql
