package Westerley::PoolManager::Controller::Backup;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use autodie qw(:all);
use DateTime;    # massive overkill, but avoid POSIX::strftime (Windows)
use Text::CSV;
use IPC::Run3;

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

subtype 'Westerley::PoolManager::EncryptTo',
	as 'ArrayRef[Str]';

coerce 'Westerley::PoolManager::EncryptTo',
	from 'Str', via { [ $_ ] };

has encrypt_to => (
	is => 'ro',
	isa => 'Westerley::PoolManager::EncryptTo',
	coerce => 1,
	required => 0,
);

has sign_with => (
	is => 'ro',
	isa => 'Str',
	required => 0,
);

has compress => (
	is  => 'ro',
	isa => subtype('Int',
		where { $_ >= 0 && $_ <= 9 },
		message { "must be int 0..9, not $_" }
	),
	required => 1,
	default  => 9,
	documentation => '0 = do not compress; 1 = fast; 9 = best',
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

sub should_crypt : Private {
	my $self = shift;

	$self->sign_with || $self->encrypt_to;
}

sub should_compress : Private {
	my $self = shift;

	# if encrypting, do not, as gnupg does compression itself
	!$self->should_crypt && $self->compress
}

sub get_fh_crypto : Private {
	my ($self, $name) = @_;
	local $_;

	$self->should_crypt
		or die "get_crypto_fh called when no crypto configured";

	my @args = ('--batch', '--yes', '--trust-model', 'always',
		'--output' => $name);
	push @args, '--sign', '--local-user', $self->sign_with if $self->sign_with;
	push @args, '--encrypt' if $self->encrypt_to;
	push @args, map(('--recipient' => $_), @{$self->encrypt_to});

	open my $fh, '|-:raw', 'gpg', @args
		or die "open gpg pipe: $! $?";
	return $fh;
}

sub get_fh_compressed : Private {
	my ($self, $name) = @_;

	$self->should_compress
		or die "get_compressed_fh called when no compression configured";

	open my $tmpfh, '>:raw', $name
		or die "Could not open $name: $!";

	my $pid = open my $fh, '|-';
	defined($pid) or die "Could not fork: $!";

	if (0 == $pid) {
		# child
		open STDOUT, '>&', $tmpfh or die "dup: $!";
		exec 'gzip', '-'.$self->compress;
		exit(1);
	}
	close $tmpfh; # belongs to child now

	return $fh;
}

sub get_fh_boring : Private {
	my ($self, $name) = @_;

	open my $fh, '>:raw', $name
		or die "open: $!";

	return $fh;
}

sub get_fh : Private {
	my ($self, $name, $nocomp) = @_;

	$self->should_crypt and return $self->get_fh_crypto($name);
	!$nocomp && $self->should_compress
		and return $self->get_fh_compressed($name);
	return $self->get_fh_boring($name);
}

sub get_name : Private {
	my ($self, $tmpl, $nocomp) = @_;

	my $now = DateTime->now;
	my $name = $now->strftime($tmpl);

	$name .= '.gz'  if $self->should_compress && !$nocomp;
	$name .= '.gpg' if $self->should_crypt;

	return $name;
}

sub op_backup : Private {
	my ($self, $c, $device) = @_;
	$c->stash(template => 'backup/op_backup.tt2');

	# this one is special, as pg_dump does its own compression
	my $zlevel = $self->should_crypt ? 0 : $self->compress;
	my $filename = $self->get_name($self->backup_relpath, 1);
	$c->stash(file => $filename);

	$c->log->info("Requesting mount of $device...");
	eval {
		$c->model('DBus')->with_mount(
			$device,
			sub {
				my $mount_path = shift;
				$c->log->debug("Mounted at $mount_path.");
				my $fullname = "$mount_path/$filename";
				my $fh = $self->get_fh($fullname, 1);

				$c->log->debug("Performing pg_dump.");
				run3 [qw(pg_dump -Fc), '-Z', $zlevel, $self->db_name], \undef, $fh,
					undef;
				$c->stash(size => -s $fullname);
			});
	};
	if ($@) {
		$c->log->error("Backup died: $@");
		$c->stash(ok => 0);
	} else {
		$c->stash(ok => 1);
	}
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

	my $filename = $self->get_name($self->export_relpath);
	$c->stash(file => $filename);

	$c->log->info("Requesting mount of $device...");
	$c->model('DBus')->with_mount(
		$device,
		sub {
			my $mount_path = shift;
			$c->log->debug("Mounted at $mount_path.");
			my $fullname = "$mount_path/$filename";

			my $fh = $self->get_fh($fullname)
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
