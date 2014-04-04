use utf8;
package Westerley::PoolManager::Schema::Result::Family;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Family

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

=head1 TABLE: C<families>

=cut

__PACKAGE__->table("families");

=head1 ACCESSORS

=head2 family_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'families_family_no_seq'

=head2 unit_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 family_name

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=cut

__PACKAGE__->add_columns(
  "family_no",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "families_family_no_seq",
  },
  "unit_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "family_name",
  { data_type => "varchar", is_nullable => 0, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</family_no>

=back

=cut

__PACKAGE__->set_primary_key("family_no");

=head1 UNIQUE CONSTRAINTS

=head2 C<families_unit_no_family_name_key>

=over 4

=item * L</unit_no>

=item * L</family_name>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "families_unit_no_family_name_key",
  ["unit_no", "family_name"],
);

=head1 RELATIONS

=head2 contacts

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Contact>

=cut

__PACKAGE__->has_many(
  "contacts",
  "Westerley::PoolManager::Schema::Result::Contact",
  { "foreign.family_no" => "self.family_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 passholders

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->has_many(
  "passholders",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { "foreign.family_no" => "self.family_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 unit_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Unit>

=cut

__PACKAGE__->belongs_to(
  "unit_no",
  "Westerley::PoolManager::Schema::Result::Unit",
  { unit_no => "unit_no" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mx9El+IvXD7U0JZv8mtU8A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
