use utf8;
package Westerley::PoolManager::Schema::Result::DocumentVersion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::DocumentVersion

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

=head1 TABLE: C<document_versions>

=cut

__PACKAGE__->table("document_versions");

=head1 ACCESSORS

=head2 document_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 version_date

  data_type: 'date'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "document_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "version_date",
  { data_type => "date", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</document_num>

=item * L</version_date>

=back

=cut

__PACKAGE__->set_primary_key("document_num", "version_date");

=head1 RELATIONS

=head2 document

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Document>

=cut

__PACKAGE__->belongs_to(
  "document",
  "Westerley::PoolManager::Schema::Result::Document",
  { document_num => "document_num" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 passholder_documents

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::PassholderDocument>

=cut

__PACKAGE__->has_many(
  "passholder_documents",
  "Westerley::PoolManager::Schema::Result::PassholderDocument",
  {
    "foreign.document_num" => "self.document_num",
    "foreign.most_recent"  => "self.version_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-30 16:54:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8nPo8UY1RcC0ruOiw3cEtw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
