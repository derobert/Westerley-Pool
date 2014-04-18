package Westerley::PoolManager::Controller::Admin;
use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Westerley::PoolManager::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	if ($c->req->params->{by_num}) {
		my $num = 0 + $c->req->params->{unit_num}; # force to number
		$c->res->redirect( $c->uri_for_action('admin/show_unit', $num), 303);
		$c->detach;
	}

	if ($c->req->params->{by_address}) {
		my $unit = $c->model('Pool::Unit')->find({ house_number => $c->req->params->{house_number}, street_ref => $c->req->params->{street_ref}});
		if ($unit) {
			$c->res->redirect( $c->uri_for_action('admin/show_unit', $unit->unit_num), 303);
			$c->detach;
		} else {
			$c->stash->{notfound} = 1
		}
	}

	$c->stash->{streets} = [
		$c->model('Pool::Street')->search(undef, {order_by => 'street_name'})
			->all
		];
}

sub show_unit :Path('/unit') Args(1) {}

=encoding utf8

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
