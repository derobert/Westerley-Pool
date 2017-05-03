use utf8;

package Westerley::PoolManager::Model::Pool::Passholder;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'Westerley::PoolManager::Schema::Result::Passholder';

sub issue_pass {
	my $self = shift;

	my $pass = $self->passes->create({
		pass_num => (int rand 2**31),
	});
	
	return $pass;
}

sub applicable_documents {
	my $self = shift;

	# DOB is passed twice for the two age checks (older than and younger
	# than)—rather hairy, but couldn't figure out how to get DBIC to
	# re-use it. :1-style placeholders didn't work.
	#
	# See DBIx::Class::Manual::FAQ for details aboput $dtf
	my $dtf = $self->result_source->storage->datetime_parser;
	$self->result_source->schema->resultset('DocVerPassholderView')->search(
		{},
		{
			bind => [$self->passholder_num,
				     $dtf->format_datetime($self->holder_dob), 
				     $dtf->format_datetime($self->holder_dob)]
		});
}

sub needed_documents {
	shift->applicable_documents->search(
		{passholder_most_recent => [undef, {'!=', \'doc_most_recent'}]});
}

sub presented_document {
	my ($self, $doc_num, $version) = @_;
	$self->result_source->schema->resultset('PassholderDocument')
		->update_or_create({
			passholder_num => $self->passholder_num,
			document_num   => $doc_num,
			most_recent    => $version
		});
	return;
}

__PACKAGE__->meta->make_immutable;
