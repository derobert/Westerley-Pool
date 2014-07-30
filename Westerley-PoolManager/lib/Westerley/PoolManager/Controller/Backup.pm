package Westerley::PoolManager::Controller::Backup;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use autodie qw(:all);
use DateTime;    # massive overkill, but avoid POSIX::strftime (Windows)

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Westerley::PoolManager::Controller::Backup - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

has db_name => (
	is       => 'ro',
	isa      => 'Str',
	required => 1
);

has destination => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => '/media/backup/pool-%Y-%m-%d_%H%M%S_%Z.pg'
);

has compression => (
	is  => 'ro',
	isa => subtype('Int',
		where { $_ >= 0 && $_ <= 9 },
		message { "must be int 0..9, not $_" }
	),
	required => 1,
	default  => 9,
);

=head1 METHODS

=cut

sub auto : Private {
	my ($self, $c) = @_;

	if (! $c->user_exists) {
		$c->log->info("No logged in user in backup");
		$c->response->redirect($c->uri_for('/user/login'));
		$c->detach;
	}

	$c->assert_user_roles( qw/backup/ );
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(media => $c->model('DBus')->removable_media);
}

sub run :Local :Args(0) {
	my ($self, $c) = @_;
	my $device = $c->req->params->{destination};

	if (($device // '') eq '') {
		$c->stash(err_no_device => 1);
		$c->detach;
	}

	my $now = DateTime->now;
	my $filename = $now->strftime($self->destination);
	$c->stash(file => $filename);

	$c->log->info("Requesting mount of $device...");
	$c->model('DBus')->with_mount(
		$device,
		sub {
			my $mount_path = shift;
			$c->log->debug("Mounted at $mount_path.");
			my $fullname = "$mount_path/$filename";

			$c->log->debug("Performing pg_dump.");
			system qw(pg_dump -Fc -f), $fullname, '-Z', $self->compression,
				$self->db_name;
			$c->stash(size => -s $fullname);
		});

	$c->stash(ok => 1);
}



=encoding utf8

=cut

__PACKAGE__->meta->make_immutable;

1;
