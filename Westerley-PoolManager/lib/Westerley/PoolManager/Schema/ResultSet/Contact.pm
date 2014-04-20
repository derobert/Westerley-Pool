use utf8;
package Westerley::PoolManager::Schema::ResultSet::Contact;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub max_order {
	my $self = shift;

	my $row = $self->search(undef, {
		select => [ 'max(me.contact_order)' ],
		as     => [ 'max_order' ],
	})->single;

	$row->get_column('max_order');
}

__PACKAGE__->meta->make_immutable;
1;
