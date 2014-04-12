use utf8;

package Westerley::PoolManager::Model::Pool::Pass;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'Westerley::PoolManager::Schema::Result::Pass';

sub allow_admission {
	my $self = shift;

	return
		   $self->pass_valid
		&& $self->passholder
		&& !$self->passholder->holder_suspended
		&& !$self->passholder->family->unit->unit_suspended;
}

__PACKAGE__->meta->make_immutable;
