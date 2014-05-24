use utf8;
package Westerley::PoolManager::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 user_num

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_user_num_seq'

=head2 user_name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 user_pwhash

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 user_active

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_num",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_user_num_seq",
  },
  "user_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "user_pwhash",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "user_active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_num>

=back

=cut

__PACKAGE__->set_primary_key("user_num");

=head1 UNIQUE CONSTRAINTS

=head2 C<users_user_name_key>

=over 4

=item * L</user_name>

=back

=cut

__PACKAGE__->add_unique_constraint("users_user_name_key", ["user_name"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Westerley::PoolManager::Schema::Result::UserRole",
  { "foreign.user_num" => "self.user_num" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-23 20:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+xMNQ1QCeFs1a3rq7e9yLw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
