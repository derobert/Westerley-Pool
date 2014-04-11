use utf8;
package Westerley::PoolManager::Schema::Result::Unit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Unit

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

=head1 TABLE: C<units>

=cut

__PACKAGE__->table("units");

=head1 ACCESSORS

=head2 unit_num

  data_type: 'integer'
  is_nullable: 0

=head2 house_number

  data_type: 'integer'
  is_nullable: 0

=head2 street_ref

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 unit_suspended

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "unit_num",
  { data_type => "integer", is_nullable => 0 },
  "house_number",
  { data_type => "integer", is_nullable => 0 },
  "street_ref",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "unit_suspended",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</unit_num>

=back

=cut

__PACKAGE__->set_primary_key("unit_num");

=head1 UNIQUE CONSTRAINTS

=head2 C<units_house_number_street_ref_key>

=over 4

=item * L</house_number>

=item * L</street_ref>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "units_house_number_street_ref_key",
  ["house_number", "street_ref"],
);

=head1 RELATIONS

=head2 families

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Family>

=cut

__PACKAGE__->has_many(
  "families",
  "Westerley::PoolManager::Schema::Result::Family",
  { "foreign.unit_num" => "self.unit_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 street

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Street>

=cut

__PACKAGE__->belongs_to(
  "street",
  "Westerley::PoolManager::Schema::Result::Street",
  { street_ref => "street_ref" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-11 03:03:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G2jmDnSisyHRKqXQV9BgDQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
