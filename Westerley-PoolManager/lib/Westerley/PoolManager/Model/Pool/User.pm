use utf8;

package Westerley::PoolManager::Model::Pool::User;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
use Crypt::Eksblowfish::Bcrypt qw(bcrypt en_base64);
use Bytes::Random::Secure qw(random_bytes);

use constant bcrypt_cost => 14;

extends 'Westerley::PoolManager::Schema::Result::User';

sub check_password {
	my ($self, $pass) = @_;

	bcrypt($pass, $self->user_pwhash) eq $self->user_pwhash;
}

sub set_password {
	my ($self, $newpass) = @_;

	my $salt = sprintf(q{$2a$%02i$%s},
		bcrypt_cost, en_base64(random_bytes(16)));
	print STDERR "salt: $salt\n";
	$self->user_pwhash(bcrypt($newpass, $salt));

	return;
}

__PACKAGE__->meta->make_immutable;
