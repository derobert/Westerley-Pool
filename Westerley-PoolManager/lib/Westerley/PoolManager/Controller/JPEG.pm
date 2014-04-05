package Westerley::PoolManager::Controller::JPEG;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

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

	if ($row) {
		$c->res->content_type('image/jpeg');
		$c->res->body($row->holder_photo);
	} else {
		$c->log->warn("Image for passholder_no = $passholder_no not found");
		$c->res->body('Image not found.');
		$c->res->status(404);
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
