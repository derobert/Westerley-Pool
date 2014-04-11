use utf8;
package Westerley::PoolManager::Schema::Result::StreetAlias;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::StreetAlias

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

=head1 TABLE: C<street_aliases>

=cut

__PACKAGE__->table("street_aliases");

=head1 ACCESSORS

=head2 street_alias

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 street_ref

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "street_alias",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "street_ref",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</street_alias>

=back

=cut

__PACKAGE__->set_primary_key("street_alias");

=head1 RELATIONS

=head2 street

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Street>

=cut

__PACKAGE__->belongs_to(
  "street",
  "Westerley::PoolManager::Schema::Result::Street",
  { street_ref => "street_ref" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-11 03:03:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FpMg4nufXrMoxruvuH0Knw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
