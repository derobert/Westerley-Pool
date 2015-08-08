use utf8;
package Westerley::PoolManager::Schema::ResultSet::Pass;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub search_printable {
	my ($self, $extra) = @_;
	$extra //= {};

	$self->search({
		'me.pass_printed' => undef,
		'me.pass_valid' => 1,
		'passholder.holder_photo' => {'!=', undef },
	}, {
		join => 'passholder',
		%$extra
	});
}

__PACKAGE__->meta->make_immutable;
1;
