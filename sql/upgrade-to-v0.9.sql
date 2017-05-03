ALTER TABLE log ADD COLUMN
  log_guests     SMALLINT CHECK (log_guests >= 0);

CREATE TABLE documents (
	document_num       SERIAL                   NOT NULL PRIMARY KEY,
	document_name      VARCHAR(100)             NOT NULL UNIQUE,
	passholder_min_age INTERVAL YEAR TO MONTH   NOT NULL,
	passholder_max_age INTERVAL YEAR TO MONTH   NOT NULL,
	CHECK(passholder_min_age < passholder_max_age)
);

CREATE TABLE document_versions (
	document_num   INTEGER  NOT NULL REFERENCES documents ON DELETE CASCADE,
	version_date   DATE     NOT NULL,
	PRIMARY KEY(document_num, version_date)
);

CREATE TABLE passholder_documents (
	passholder_num INTEGER NOT NULL REFERENCES passholders ON DELETE CASCADE,
	document_num   INTEGER NOT NULL REFERENCES documents ON DELETE CASCADE,
	most_recent    DATE NOT NULL,
	PRIMARY KEY(passholder_num, document_num),
	CONSTRAINT ph_docs_version_exists
	  FOREIGN KEY (document_num, most_recent)
	  REFERENCES document_versions(document_num, version_date)
	  ON DELETE CASCADE;
);
