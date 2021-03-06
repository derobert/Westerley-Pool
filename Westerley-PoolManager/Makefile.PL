#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Westerley-PoolManager';
all_from 'lib/Westerley/PoolManager.pm';

requires 'Catalyst::Runtime' => '5.90053';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

# Earlier versions are pretty broken.
requires 'DBIx::Class::Helper::ResultSet::AutoRemoveColumns' => '2.021001';
requires 'DBIx::Class::Helper::ResultSet::RemoveColumns' => '2.021001';

requires 'DBD::Pg';
requires 'DateTime::Format::Pg';

requires 'Cairo';
requires 'Pango';
requires 'Gtk2';
requires 'Barcode::Code128';

requires 'Crypt::Eksblowfish::Bcrypt';
requires 'Bytes::Random::Secure';

requires 'Text::CSV';
requires 'Net::DBus' => '1.0.0.1';
requires 'IPC::Run3';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
