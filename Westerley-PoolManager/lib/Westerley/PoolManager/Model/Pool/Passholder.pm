use utf8;

package Westerley::PoolManager::Model::Pool::Passholder;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'Westerley::PoolManager::Schema::Result::Passholder';

sub issue_pass {
	my $self = shift;

	my $pass = $self->passes->create({
		pass_num => (int rand 2**31),
	});
	
	return $pass;
}

__PACKAGE__->meta->make_immutable;
