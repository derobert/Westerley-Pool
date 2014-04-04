use utf8;
package Westerley::PoolManager::Schema::Result::ContactPhone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::ContactPhone

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

=head1 TABLE: C<contact_phones>

=cut

__PACKAGE__->table("contact_phones");

=head1 ACCESSORS

=head2 contact_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 phone_number

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 phone_label

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "contact_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "phone_number",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "phone_label",
  { data_type => "varchar", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</contact_no>

=item * L</phone_number>

=back

=cut

__PACKAGE__->set_primary_key("contact_no", "phone_number");

=head1 RELATIONS

=head2 contact_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Contact>

=cut

__PACKAGE__->belongs_to(
  "contact_no",
  "Westerley::PoolManager::Schema::Result::Contact",
  { contact_no => "contact_no" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:anfLK+wUo8uaahKuqeh4Vw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
