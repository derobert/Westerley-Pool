package Westerley::PoolManager::Controller::Documents;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Westerley::PoolManager::Controller::Documents - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub auto : Private {
	my ($self, $c) = @_;

	if (! $c->user_exists) {
		$c->log->info("No logged in user in documents");
		$c->response->redirect($c->uri_for('/user/login'));
		$c->detach;
	}

	$c->assert_user_roles( qw/documents/ );
}

sub index : Path('/documents') Args(0) {
	my ($self, $c) = @_;

	$c->stash->{docs} = $c->model('Pool::Document')->search(
		{},
		{
			order_by => [
				{-asc  => 'me.document_name'},
				{-desc => 'document_versions.version_date'}
			],
			prefetch => ['document_versions']});
}

sub doc_capture : Chained('/') PathPart('document') CaptureArgs(1) {
	my ($self, $c, $document_num) = @_;
	$c->stash->{document} = ('new' eq $document_num)
		? $c->model('Pool::Document')->new_result({})
		: $c->model('Pool::Document')->find($document_num);
	$c->stash->{document_num} = $document_num;
}

sub edit : Chained('doc_capture') PathPath('edit') Args(0) {
	my ($self, $c) = @_;
	my $doc = $c->stash->{document};
	
	if (defined(my $op = $c->req->params->{op})) {
		if ('save' eq $op) {
			$doc->document_name($c->req->params->{name});
			$doc->passholder_min_age($c->req->params->{min_age});
			$doc->passholder_max_age($c->req->params->{max_age});
			$doc->update_or_insert;
			$c->response->redirect($c->uri_for_action('/documents/index'), 303);
			$c->detach;
		} else {
			die "Unknown op: $op";
		}
	}
}

sub versions : Chained('doc_capture') PathParth('versions') Args(0) {
	my ($self, $c) = @_;
	my $doc = $c->stash->{document};

	if (defined(my $op = $c->req->params->{op})) {
		if ('add' eq $op) {
			$doc->document_versions->create(
				{version_date => $c->req->params->{version}});
			$c->response->redirect($c->uri_for_action('/documents/index'), 303);
			$c->detach;
		} else {
			die "Unknown op: $op";
		}
	}

	$c->stash->{document_versions} = [ $doc->document_versions->search({}, { order_by => { -asc => 'me.version_date' } }) ];
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
