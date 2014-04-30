package Westerley::PoolManager::Color;
use Moose;

has [qw(red green blue)] => (is => 'rw', isa => 'Num', required => 1);

sub as_list {
	my $self = shift;
	wantarray or die "as_list must be in list context";

	return $self->red, $self->green, $self->blue;
}

sub css {
	my $self = shift;
	local $_;

	return 'rgb('
		. join(q{,},
		map(int(0.5 + 255 * $_), $self->as_list))
		. ')';
}

__PACKAGE__->meta->make_immutable;

