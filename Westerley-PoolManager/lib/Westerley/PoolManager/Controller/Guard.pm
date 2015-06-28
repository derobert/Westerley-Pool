package Westerley::PoolManager::Controller::Guard;
use Moose;
use namespace::autoclean;
use Data::Dump qw(pp);

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

	$c->stash->{streets} = [
		$c->model('Pool::Street')->search(undef, {order_by => 'street_name'})
			->all
		];
    $c->stash->{search} = $c->uri_for('search');
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

	$c->stash->{from_search} = 1 if $c->req->params->{from_search};
}

sub checkin :Local :Args(0) :POST {
	my ($self, $c) = @_;
	$c->stash->{current_view} = 'JSON';

	# FIXME: This winds up pulling the jpeg...
	my $row = $c->model('Pool::Pass')->find($c->req->params->{pass_num}, {
		prefetch => {
			passholder => { family => { unit => 'street' } },
		},
	});
	if ($row) {
		$c->model('Pool')->log_pass(checkin => $row);
		$c->stash->{JSON} = { status => 1 };
	} else {
		$c->stash->{JSON} = { status => 0 };
	}

}

sub search :Local :Args(0) {
	my ($self, $c) = @_;

	my %criteria;
	my $params = $c->req->params;
	$criteria{'unit.house_number'} = $params->{house_number}
		if ($params->{house_number} // '') ne '';
	$criteria{'unit.street_ref'} = $params->{street_ref}
		if ($params->{street_ref} // '') ne '';

	if (!%criteria) {
		$c->stash->{error} = 'No search criteria specified.';
		$c->detach;
	}

	# always only show valid
	$criteria{'me.pass_valid'} = 1;

	$c->log->debug("Criteria: " . pp \%criteria);
	$c->stash->{passes} = [
		$c->model('Pool::Pass')->search(
			\%criteria,
			{
				prefetch =>
					{passholder => {family => {unit => 'street'}, age_group => undef}},
				order_by =>
					['unit.unit_num', 'family.family_num', 'passholder.holder_name'],
			})];
}

sub today : Local Args(0) {
	my ($self, $c) = @_;

	$c->stash->{checkin} = [
		$c->model('Pool::Log')->search({
				log_type => 'checkin',
				log_time => {'>=', \q{DATE_TRUNC('day', CURRENT_TIMESTAMP)}}})];
	$c->stash->{scanned} = [
		$c->model('Pool::Log')->search({
				log_type => 'view',
				log_time => {'>=', \q{DATE_TRUNC('day', CURRENT_TIMESTAMP)}}})];
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
