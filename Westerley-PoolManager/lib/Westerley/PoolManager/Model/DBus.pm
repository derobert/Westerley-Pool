use utf8;
package Westerley::PoolManager::Model::DBus;

use Moose;
use namespace::autoclean;
use Net::DBus;
use Carp;
extends 'Catalyst::Model';

has _system_bus => (
	is      => 'ro',
	isa     => 'Net::DBus',
	default => sub {
		Net::DBus->system(nomainloop => 1)
			or confess "Could not connect to system DBus";
	},
);

sub udisks2 {
	my $self = shift;
	$self->_system_bus->get_service('org.freedesktop.UDisks2')
		or confess "Could not find UDisks2 service.";
}

sub removable_media {
	local $_;
	my $self = shift;
	my $ud   = $self->udisks2;
	my $manager = $ud->get_object('/org/freedesktop/UDisks2',
	                              'org.freedesktop.DBus.ObjectManager')
		or confess "Could not get UDisks2 ObjectManager";

	my $objs = $manager->GetManagedObjects
		or confess "Could not get managed objects from the ObjectManager";

	# filter for removable drives
	my %removable;
	my %empty;
	while (my ($k, $v) = each %$objs) {
		my $drive = $v->{'org.freedesktop.UDisks2.Drive'}
			or next;
		$drive->{Removable}    # includes removable media per docs
			or next;
		if ($drive->{MediaAvailable}) {
			$removable{$k} = $drive;
		} else {
			$empty{$k} = $drive;
		}
	}

	# now for the block devices.
	my %fs;
	while (my ($k, $v) = each %$objs) {
		my $block = $v->{'org.freedesktop.UDisks2.Block'}
			or next;
		exists $removable{$block->{Drive}}
			or next;
		# NOTE: This does not support LUKS (disk encryption). Seems like
		# if we want crypto, gpg is a far better option.
		$block->{IdUsage} eq 'filesystem'
			or next;
		$fs{$k} = $block;
	}

	return {
		filesystems => \%fs,
		drives      => \%removable,
		empty       => \%empty,
		data        => $objs,
	};
}

1;
