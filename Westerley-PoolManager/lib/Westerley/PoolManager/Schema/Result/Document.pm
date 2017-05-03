use utf8;
package Westerley::PoolManager::Schema::Result::Document;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Document

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

=head1 TABLE: C<documents>

=cut

__PACKAGE__->table("documents");

=head1 ACCESSORS

=head2 document_num

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'documents_document_num_seq'

=head2 document_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 passholder_min_age

  data_type: 'interval'
  is_nullable: 0

=head2 passholder_max_age

  data_type: 'interval'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "document_num",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "documents_document_num_seq",
  },
  "document_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "passholder_min_age",
  { data_type => "interval", is_nullable => 0 },
  "passholder_max_age",
  { data_type => "interval", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</document_num>

=back

=cut

__PACKAGE__->set_primary_key("document_num");

=head1 UNIQUE CONSTRAINTS

=head2 C<documents_document_name_key>

=over 4

=item * L</document_name>

=back

=cut

__PACKAGE__->add_unique_constraint("documents_document_name_key", ["document_name"]);

=head1 RELATIONS

=head2 document_versions

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::DocumentVersion>

=cut

__PACKAGE__->has_many(
  "document_versions",
  "Westerley::PoolManager::Schema::Result::DocumentVersion",
  { "foreign.document_num" => "self.document_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 passholder_documents

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::PassholderDocument>

=cut

__PACKAGE__->has_many(
  "passholder_documents",
  "Westerley::PoolManager::Schema::Result::PassholderDocument",
  { "foreign.document_num" => "self.document_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-30 16:54:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yYMMLETOmoUR36eY7h/lNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
