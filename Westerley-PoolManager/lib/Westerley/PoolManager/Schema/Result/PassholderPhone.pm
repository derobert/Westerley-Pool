use utf8;
package Westerley::PoolManager::Schema::Result::PassholderPhone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::PassholderPhone

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

=head1 TABLE: C<passholder_phones>

=cut

__PACKAGE__->table("passholder_phones");

=head1 ACCESSORS

=head2 passholder_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 phone_label

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 phone_number

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "passholder_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "phone_label",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "phone_number",
  { data_type => "varchar", is_nullable => 0, size => 20 },
);

=head1 RELATIONS

=head2 passholder_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Passholder>

=cut

__PACKAGE__->belongs_to(
  "passholder_no",
  "Westerley::PoolManager::Schema::Result::Passholder",
  { passholder_no => "passholder_no" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5hxUXoBp63GVneDzH22Piw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
