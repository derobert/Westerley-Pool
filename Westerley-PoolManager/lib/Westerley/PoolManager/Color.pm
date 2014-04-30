package Westerley::PoolManager::Color;
use Moose;

has [qw(red green blue)] => (is => 'rw', isa => 'Num', required => 1);

sub css {
	my $self = shift;
	local $_;

	return 'rgb('
		. join(q{,},
		map(int(0.5 + 255 * $_), $self->red, $self->green, $self->blue))
		. ')';
}

__PACKAGE__->meta->make_immutable;

