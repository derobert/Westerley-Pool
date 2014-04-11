use utf8;
package Westerley::PoolManager::Schema::Result::PassholderContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::PassholderContact

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

=head1 TABLE: C<passholder_contacts>

=cut

__PACKAGE__->table("passholder_contacts");

=head1 ACCESSORS

=head2 passholder_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contact_num

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contact_order

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "passholder_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contact_num",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contact_order",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</passholder_num>

=item * L</contact_num>

=back

=cut

__PACKAGE__->set_primary_key("passholder_num", "contact_num");

=head1 RELATIONS

=head2 contact

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "contact",
  "Westerley::PoolManager::Schema::Result::Contact",
  { contact_num => "contact_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 passholder

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->belongs_to(
  "passholder",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { passholder_num => "passholder_num" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-11 02:04:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NcFnAaYbhOiLmw/rqJU0UQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
