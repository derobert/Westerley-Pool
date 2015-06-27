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

Pull up a web browser and visit http://localhost/ to make sure it's
working.

Backup
------

The backup code can now (optionally) encrypt and sign backups. Crypto is
done through GnuPG. There are a few steps to enabling it:

First, switch to the `pool-mgr` user.

Signing backups requires generating a keypair. To do so, run `gpg
--gen-key`. When prompted, pick either "RSA (sign only)" or "RSA and RSA
(default)". I suggest a reasonably long key, at least 3072 bits.
Probably shouldn't expire. You can put whatever you want for "Real
name"; email and comment can be left blank. When prompted, *leave the
passphrase blank.* You'll might be asked if you're sure a few times.

After generating the key (which may take a bit), it will output some
information. Look for the "key fingerprint":

    pub   3072R/78756524 2015-06-27
          Key fingerprint = 1268 BCC4 3077 B320 F0BC  E763 DF41 2F98 7875 6524
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you write that without spaces and put a 0x in front (e.g.,
`0x1268BCC43077B320F0BCE763DF412F9878756524`) then that's the KEY-ID.

Second, some useful gpg commands to move keys around:

	# export a public key to a file
    gpg --armor --output pubkeyfile.gpg --export KEY-ID

	# import a public key from a file
	gpg --import pubkeyfile.gpg

	# export a public key to the key servers
	gpg --send-keys KEY-ID

	# import a public key from the key servers
	gpg --recv-keys KEY-ID

Next, you'll need to decide which keys you want to be able to *read*
(decrypt) the backups. Import those public keys; see the commands above.

Finally, edit `westerley_poolmanager.conf` (located in
`Westerley-Pool/Westerley-PoolManager`) and look for the
`<Component Controller::Backup>` section. You should see commented out
`sign_with` and `encrypt_to` directives. Put the KEY-ID of the key you
generated above as `sign_with`. Now put as many `encrypt_to`
directives as you need to specify all the people able to decrypt/read
the backups (use KEY-IDs for them, too).

After editing the configuration file, restart the program by running
`systemctl restart westerley-poolmanager.service` (the config is only
read when starting).
