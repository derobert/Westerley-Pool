package Westerley::PoolManager::Controller::JPEG;
use Moose;
use namespace::autoclean;
use HTTP::Status qw(HTTP_SEE_OTHER);

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(
	image_missing_uri => '/static/images/missing.svg',
);

=head1 NAME

Westerley::PoolManager::Controller::JPEG - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub view :Local :Args(1) {
	my ($self, $c, $passholder_no) = @_;

	my $row = $c->model('Pool::Passholder')->find(
		$passholder_no, { key => 'primary', columns => [ 'holder_photo' ] });

	if ($row && defined $row->holder_photo) {
		$c->res->content_type('image/jpeg');
		$c->res->body($row->holder_photo);
	} elsif ($row) {
		$c->log->debug("Passholder $passholder_no has NULL image");
		$c->res->redirect($c->uri_for($self->{image_missing_uri}),
			HTTP_SEE_OTHER);
	} else {
		$c->log->warn("Row for passholder_no = $passholder_no not found");
		$c->res->body('Passholder not found.');
		$c->res->status(404);
	}
}



=encoding utf8

=head1 AUTHOR

Anthony DeRobertis,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under GPL v3 or later.

=cut

__PACKAGE__->meta->make_immutable;

1;
