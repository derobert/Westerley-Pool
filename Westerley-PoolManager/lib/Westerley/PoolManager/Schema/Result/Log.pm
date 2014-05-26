use utf8;
package Westerley::PoolManager::Schema::Result::Log;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Log

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

=head1 TABLE: C<log>

=cut

__PACKAGE__->table("log");

=head1 ACCESSORS

=head2 log_num

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'log_log_num_seq'

=head2 log_time

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 log_type

  data_type: 'enum'
  extra: {custom_type_name => "log_entry_type",list => ["view","checkin","checkout"]}
  is_nullable: 0

=head2 pass_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 holder_name

  data_type: 'varchar'
  default_value: 'N/A'
  is_nullable: 0
  size: 100

=head2 family_name

  data_type: 'varchar'
  default_value: 'N/A'
  is_nullable: 0
  size: 30

=head2 house_number

  data_type: 'integer'
  default_value: -1
  is_nullable: 0

=head2 street_name

  data_type: 'varchar'
  default_value: 'N/A'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "log_num",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "log_log_num_seq",
  },
  "log_time",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "log_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "log_entry_type",
      list => ["view", "checkin", "checkout"],
    },
    is_nullable => 0,
  },
  "pass_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "holder_name",
  {
    data_type => "varchar",
    default_value => "N/A",
    is_nullable => 0,
    size => 100,
  },
  "family_name",
  {
    data_type => "varchar",
    default_value => "N/A",
    is_nullable => 0,
    size => 30,
  },
  "house_number",
  { data_type => "integer", default_value => -1, is_nullable => 0 },
  "street_name",
  {
    data_type => "varchar",
    default_value => "N/A",
    is_nullable => 0,
    size => 100,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</log_num>

=back

=cut

__PACKAGE__->set_primary_key("log_num");

=head1 RELATIONS

=head2 pass

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Pass>

=cut

__PACKAGE__->belongs_to(
  "pass",
  "Westerley::PoolManager::Schema::Result::Pass",
  { pass_num => "pass_num" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-25 13:19:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zIS02NBc4DWQKN35KUtYiw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
