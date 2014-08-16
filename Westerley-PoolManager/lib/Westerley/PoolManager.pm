package Westerley::PoolManager;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    StackTrace

    Authentication
	Authorization::Roles

    Session
    Session::Store::DBIC
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in westerley_poolmanager.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name => 'Westerley::PoolManager',
	# Disable deprecated behavior needed by old applications
	disable_component_resolution_regex_fallback => 1,
	abort_chain_on_error_fix       => 1,       # don't continue after error
	use_hash_multivalue_in_request => 1,
	enable_catalyst_header         => 1,       # Send X-Catalyst header
	encoding                       => 'UTF-8',

	'Plugin::Authentication' => {
		default => {
			credential => {
				class         => 'Password',
				password_type => 'self_check',
			},
			store => {
				class         => 'DBIx::Class',
				user_model    => 'Pool::User',
				role_relation => 'roles',
				role_field    => 'role_name',
			},
		},
	},
	'Plugin::Session' => {
		dbic_class     => 'Pool::Session',
		id_field       => 'session_id',
		data_field     => 'session_data',
		expires_field  => 'session_expires',
		cookie_expires => 0,
	},
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

Westerley::PoolManager - Catalyst based application

=head1 SYNOPSIS

    script/westerley_poolmanager_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Westerley::PoolManager::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
