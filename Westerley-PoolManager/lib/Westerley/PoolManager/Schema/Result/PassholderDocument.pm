use utf8;
package Westerley::PoolManager::Schema::Result::PassholderDocument;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::PassholderDocument

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<passholder_documents>

=cut

__PACKAGE__->table("passholder_documents");

=head1 ACCESSORS

=head2 passholder_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 document_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 most_recent

  data_type: 'date'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "passholder_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "document_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "most_recent",
  { data_type => "date", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</passholder_num>

=item * L</document_num>

=back

=cut

__PACKAGE__->set_primary_key("passholder_num", "document_num");

=head1 RELATIONS

=head2 document

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Document>

=cut

__PACKAGE__->belongs_to(
  "document",
  "Westerley::PoolManager::Schema::Result::Document",
  { document_num => "document_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 document_version

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::DocumentVersion>

=cut

__PACKAGE__->belongs_to(
  "document_version",
  "Westerley::PoolManager::Schema::Result::DocumentVersion",
  { document_num => "document_num", version_date => "most_recent" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 passholder

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->belongs_to(
  "passholder",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { passholder_num => "passholder_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-03 18:50:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V/17sD/38j8wtt6dpfoPyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
