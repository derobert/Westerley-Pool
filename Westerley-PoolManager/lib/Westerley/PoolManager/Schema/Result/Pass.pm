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

=head2 pass_num

  data_type: 'integer'
  is_nullable: 0

=head2 passholder_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 pass_issued

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 pass_valid

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 pass_printed

  data_type: 'timestamp with time zone'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "pass_num",
  { data_type => "integer", is_nullable => 0 },
  "passholder_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "pass_issued",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "pass_valid",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "pass_printed",
  { data_type => "timestamp with time zone", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</pass_num>

=back

=cut

__PACKAGE__->set_primary_key("pass_num");

=head1 RELATIONS

=head2 logs

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::Log>

=cut

__PACKAGE__->has_many(
  "logs",
  "Westerley::PoolManager::Schema::Result::Log",
  { "foreign.pass_num" => "self.pass_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 passholder

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->belongs_to(
  "passholder",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { passholder_num => "passholder_num" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-07-29 04:53:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cZ/WtFAYxrLoaEM/WBX97g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
