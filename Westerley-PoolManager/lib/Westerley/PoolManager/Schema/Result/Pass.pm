use utf8;
package Westerley::PoolManager::Schema::Result::Pass;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Pass

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

=head1 TABLE: C<passes>

=cut

__PACKAGE__->table("passes");

=head1 ACCESSORS

=head2 pass_no

  data_type: 'integer'
  is_nullable: 0

=head2 passholder_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 pass_issued

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 pass_valid

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "pass_no",
  { data_type => "integer", is_nullable => 0 },
  "passholder_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "pass_issued",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "pass_valid",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</pass_no>

=back

=cut

__PACKAGE__->set_primary_key("pass_no");

=head1 RELATIONS

=head2 passholder_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->belongs_to(
  "passholder_no",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { passholder_no => "passholder_no" },
  { is_deferrable => 0, on_delete => "SET NULL", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8mqqrN7YPPhkI8f8eX9bFQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
