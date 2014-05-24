use utf8;
package Westerley::PoolManager::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::UserRole

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

=head1 TABLE: C<user_roles>

=cut

__PACKAGE__->table("user_roles");

=head1 ACCESSORS

=head2 user_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_num>

=item * L</role_num>

=back

=cut

__PACKAGE__->set_primary_key("user_num", "role_num");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Westerley::PoolManager::Schema::Result::Role",
  { role_num => "role_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Westerley::PoolManager::Schema::Result::User",
  { user_num => "user_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-23 20:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LiQhrnATE3wVJxMTnDF6EQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
