package Westerley::PoolManager::Controller::Guard;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Westerley::PoolManager::Controller::Guard - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{search_by_name} = $c->uri_for('search');
    $c->stash->{lookup_by_pass_no} = $c->uri_for('pass');
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub pass :Local :Args(1) {
	my ($self, $c, $pass_no) = @_;
	$c->stash->{pass_no} = $pass_no;

	# FIXME: This winds up pulling the jpeg...
	my $row = $c->model('Pool::Pass')->find($pass_no, {
		prefetch => {
			passholder => { family => { unit => 'street' } ,
			                age_group => undef },
		},
	});
	if (!$row) {
		$c->response->status(404);
		$c->detach;
	}

	$c->stash->{pass} = $row;
	$c->stash->{photo_uri} = $c->uri_for('/jpeg/view', $row->passholder->passholder_num)
		if $row->passholder;

	my $op = $c->req->params->{op} // '';
	if ('checkin' eq $op) {
		$c->model('Pool')->log_pass(checkin => $row);
		$c->stash(checked_in => 1);
	} else {
		$c->model('Pool')->log_pass(view => $row);
	}
}


=encoding utf8

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
