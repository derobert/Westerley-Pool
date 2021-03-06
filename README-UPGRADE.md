Notes on Upgrading
==================

Read the notes starting from the version you're upgrading from.

Upgrades from v0.7
------------------

There are schema changes in v0.8 to support issued but not yet printed
passes. (This allows you to use the search-by-address feature to admit
people before you've actually printed a pass for them.)

SQL to upgrade your database is in `sql/upgrade-to-v0.8.sql`. In addition,
you must run *outside of a transaction* `sql/upgrade-to-v0.8-p2.sql`.
(This adds some more acceptable log types, but unfortunately PostgreSQL
does not allow `ALTER TYPE ADD VALUE` inside a transaction).

Upgrades from 0.8
-----------------

There are schema changes to support logging the number of guests on
checkin and storing which documents each passholder has been presented.
Please run `sql/upgrade-to-v0.9.sql` against your database.

There is a new role, documents, to manage documents & their versions.
The upgrade SQL adds it to the database, but you'll have to add your
users to it by hand. The sample-admin.sql file has been updated if you
need an example.
