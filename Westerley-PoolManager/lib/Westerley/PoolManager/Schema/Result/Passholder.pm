use utf8;
package Westerley::PoolManager::Schema::Result::Passholder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Passholder

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

=head1 TABLE: C<passholders>

=cut

__PACKAGE__->table("passholders");

=head1 ACCESSORS

=head2 passholder_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'passholders_passholder_no_seq'

=head2 family_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 holder_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 holder_dob

  data_type: 'date'
  is_nullable: 0

=head2 holder_can_swim

  data_type: 'boolean'
  is_nullable: 0

=head2 holder_suspended

  data_type: 'boolean'
  is_nullable: 0

=head2 holder_photo

  data_type: 'bytea'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "passholder_no",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "passholders_passholder_no_seq",
  },
  "family_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "holder_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "holder_dob",
  { data_type => "date", is_nullable => 0 },
  "holder_can_swim",
  { data_type => "boolean", is_nullable => 0 },
  "holder_suspended",
  { data_type => "boolean", is_nullable => 0 },
  "holder_photo",
  { data_type => "bytea", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</passholder_no>

=back

=cut

__PACKAGE__->set_primary_key("passholder_no");

=head1 UNIQUE CONSTRAINTS

=head2 C<passholders_holder_name_family_no_key>

=over 4

=item * L</holder_name>

=item * L</family_no>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "passholders_holder_name_family_no_key",
  ["holder_name", "family_no"],
);

=head1 RELATIONS

=head2 family_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Family>

=cut

__PACKAGE__->belongs_to(
  "family_no",
  "Westerley::PoolManager::Schema::Result::Family",
  { family_no => "family_no" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 passes

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Pass>

=cut

__PACKAGE__->has_many(
  "passes",
  "Westerley::PoolManager::Schema::Result::Pass",
  { "foreign.passholder_no" => "self.passholder_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 passholder_contacts

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::PassholderContact>

=cut

__PACKAGE__->has_many(
  "passholder_contacts",
  "Westerley::PoolManager::Schema::Result::PassholderContact",
  { "foreign.passholder_no" => "self.passholder_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 passholder_phones

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::PassholderPhone>

=cut

__PACKAGE__->has_many(
  "passholder_phones",
  "Westerley::PoolManager::Schema::Result::PassholderPhone",
  { "foreign.passholder_no" => "self.passholder_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 18:51:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JpazLdBNAwaG2cpC9NpUYw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
