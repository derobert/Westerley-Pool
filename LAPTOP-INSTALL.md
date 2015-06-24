Installing Pool Manager on a Laptop
===================================

This is written for Debian/jessie. Probably not much different on
Ubuntu, but untested. Note that Jessie-Backports must be enabled (added
to `sources.list`) for `libnet-dbus-perl`.


Packages
--------

Install the following packages (which will pull in a lot of dependencies
as well). Note when I did this, aptitude was set to install recommended
packages:

	git udisks2 starman postgresql libmodule-install-perl libcatalyst-perl
	libcatalyst-devel-perl libcatalyst-modules-perl
	libdbix-class-helpers-perl libdbd-pg-perl libdatetime-format-pg-perl
	libcairo-perl libpango-perl libgtk2-perl libbarcode-code128-perl
	libcrypt-eksblowfish-perl libbytes-random-secure-perl
	libtext-csv-perl libtext-csv-xs-perl libipc-run3-perl
	libipc-system-simple-perl libnet-dbus-perl/jessie-backports 

Note that `libcatalyst-devel-perl` probably is not required, except for
the double-check step (Makefile.PL)


User
----

1. `adduser --disabled-password --group --system pool-mgr`
2. `chsh -s /bin/bash pool-mgr`
3. `su -l postgres -c 'createuser pool-mgr'`
4. `su -l postgres -c 'createdb -O pool-mgr -E UTF8 westerley'`


Logs
----

    mkdir /var/log/pool-manager
    chown pool-mgr:adm /var/log/pool-manager
    chmod u=rwx,g=rxs,o= /var/log/pool-manager/


Software
--------

Switch to the pool-mgr user (`su - pool-mgr` or `sudo -u pool-mgr -i`)
and clone the repository. Of course, you can use your own fork here.

    git clone https://github.com/derobert/Westerley-Pool.git

Switch into the Westerley-Pool/Westerley-PoolManager and, just to
double-check the dependencies, run `perl Makefile.PL`.

Next, in `~/Westerley-Pool/sql`, run `psql westerley`. Then type the
following:

    BEGIN;
    \i pool.sql
    \i sample.sql
    COMMIT;
    \q

To add a sample administrator account to the system (username admin,
password admin) additionally `\i sample-admin.sql`.

Note that sample.sql contains sample data, and you may not want to load
it.

Back as root, copy the `integration/westerley-poolmanager.service` file to
`/etc/systemd/system/` and then:

    systemctl enable westerley-poolmanager.service
    systemctl start westerley-poolmanager.service

Finally, copy `integration/westerley-poolmanager.pkla` to
`/etc/polkit-1/localauthority/50-local.d/`. Polkit will automatically
read the new file.
