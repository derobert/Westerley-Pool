use utf8;
package Westerley::PoolManager::Schema::Result::Street;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Street

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

=head1 TABLE: C<streets>

=cut

__PACKAGE__->table("streets");

=head1 ACCESSORS

=head2 street_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "street_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</street_name>

=back

=cut

__PACKAGE__->set_primary_key("street_name");

=head1 RELATIONS

=head2 street_aliases

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::StreetAlias>

=cut

__PACKAGE__->has_many(
  "street_aliases",
  "Westerley::PoolManager::Schema::Result::StreetAlias",
  { "foreign.street_name" => "self.street_name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 units

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Unit>

=cut

__PACKAGE__->has_many(
  "units",
  "Westerley::PoolManager::Schema::Result::Unit",
  { "foreign.street_name" => "self.street_name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qotM4tjRUf/js7sxtWLMqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
