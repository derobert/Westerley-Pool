use utf8;

package Westerley::PoolManager::Model::Pool::User;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
use Crypt::Eksblowfish::Bcrypt qw(bcrypt);

extends 'Westerley::PoolManager::Schema::Result::User';

sub check_password {
	my ($self, $pass) = @_;

	bcrypt($pass, $self->user_pwhash) eq $self->user_pwhash;
}

__PACKAGE__->meta->make_immutable;
