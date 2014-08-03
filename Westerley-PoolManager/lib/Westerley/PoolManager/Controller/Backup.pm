package Westerley::PoolManager::Controller::Backup;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use autodie qw(:all);
use DateTime;    # massive overkill, but avoid POSIX::strftime (Windows)
use Text::CSV;

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

has backup_relpath => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'backup-%Y-%m-%d_%H%M%S_%Z.pg'
);

has export_relpath => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'export-%Y-%m-%d_%H%M%S_%Z.csv'
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
	my $op = $c->req->params->{op};

	if (($device // '') eq '') {
		$c->stash(err_no_device => 1);
		$c->detach;
	}

	if (($op // '') eq '') {
		$c->stash(err_no_op => 1);
	} elsif ('backup' eq $op) {
		$c->detach(op_backup => [ $device ]);
	} elsif ('log_exp' eq $op) {
		$c->detach(op_log_export => [ $device ]);
	} else {
		$c->stash(err_bad_op => $op);
		$c->detach;
	}

}

sub op_backup : Private {
	my ($self, $c, $device) = @_;
	$c->stash(template => 'backup/op_backup.tt2');

	my $now = DateTime->now;
	my $filename = $now->strftime($self->backup_relpath);
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

sub op_log_export : Private {
	my ($self, $c, $device) = @_;
	$c->stash(template => 'backup/op_log_export.tt2');

	my $CSV = Text::CSV->new({
			eol          => "\015\012",
			always_quote => 1,
			auto_diag    => 2,
			diag_verbose => 1,
		}) or die "Could not make CSV";

	my $log = $c->model('Pool::Log')->search(undef, { order_by => 'log_num'})
		or die "No log?";

	my $now = DateTime->now;
	my $filename = $now->strftime($self->export_relpath);
	$c->stash(file => $filename);

	$c->log->info("Requesting mount of $device...");
	$c->model('DBus')->with_mount(
		$device,
		sub {
			my $mount_path = shift;
			$c->log->debug("Mounted at $mount_path.");
			my $fullname = "$mount_path/$filename";

			open my $fh, '>', $fullname
				or die "Could not open $fullname: $!";
			
			my @cols = $log->result_source->columns;
			$CSV->print($fh, \@cols);

			while (my $rec = $log->next) {
				$CSV->print($fh, [ map $rec->get_column($_), @cols ]);
			}

			close $fh
				or die "Could not close $fullname: $!";
			
			$c->stash(size => -s $fullname);
		});

	$c->stash(ok => 1);
}



=encoding utf8

=cut

__PACKAGE__->meta->make_immutable;

1;
