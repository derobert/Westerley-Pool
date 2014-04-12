use utf8;
package Westerley::PoolManager::Schema::Result::AgeGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::AgeGroup

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

=head1 TABLE: C<age_groups>

=cut

__PACKAGE__->table("age_groups");

=head1 ACCESSORS

=head2 age_group_num

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'age_groups_age_group_num_seq'

=head2 age_group_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 min_age

  data_type: 'interval'
  is_nullable: 0

=head2 max_age

  data_type: 'interval'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "age_group_num",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "age_groups_age_group_num_seq",
  },
  "age_group_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "min_age",
  { data_type => "interval", is_nullable => 0 },
  "max_age",
  { data_type => "interval", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</age_group_num>

=back

=cut

__PACKAGE__->set_primary_key("age_group_num");

=head1 UNIQUE CONSTRAINTS

=head2 C<age_groups_age_group_name_key>

=over 4

=item * L</age_group_name>

=back

=cut

__PACKAGE__->add_unique_constraint("age_groups_age_group_name_key", ["age_group_name"]);

=head2 C<age_groups_max_age_key>

=over 4

=item * L</max_age>

=back

=cut

__PACKAGE__->add_unique_constraint("age_groups_max_age_key", ["max_age"]);

=head2 C<age_groups_min_age_key>

=over 4

=item * L</min_age>

=back

=cut

__PACKAGE__->add_unique_constraint("age_groups_min_age_key", ["min_age"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-12 01:01:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4JqykqSZKRpt0beoZY95DQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
