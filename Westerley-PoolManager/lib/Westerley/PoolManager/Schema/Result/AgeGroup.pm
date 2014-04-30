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

=head2 age_group_color

  data_type: 'rgb_color'
  is_nullable: 0

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
  "age_group_color",
  { data_type => "rgb_color", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-29 22:44:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e6pg+cm5aIeM5VK/tWrlfg

use Westerley::PoolManager::Color;

__PACKAGE__->inflate_column('age_group_color', {
	inflate => sub {
		my ($val, $rs) = @_;
		$val =~ /^\(([0-9.]+),([0-9.]+),([0-9.]+)\)$/
			or die "Invalud color: $val";
		Westerley::PoolManager::Color->new(
			red => $1,
			green => $2,
			blue => $3
		);
	}, deflate => sub {
		my ($col, $rs) = @_;

		'(' . join(q{,}, $col->as_list) . ')';
	}
});

__PACKAGE__->meta->make_immutable;
1;
