use utf8;
package Westerley::PoolManager::Schema::Result::Contact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Westerley::PoolManager::Schema::Result::Contact

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

=head1 TABLE: C<contacts>

=cut

__PACKAGE__->table("contacts");

=head1 ACCESSORS

=head2 contact_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'contacts_contact_no_seq'

=head2 family_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contact_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 contact_notes

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "contact_no",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "contacts_contact_no_seq",
  },
  "family_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contact_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "contact_notes",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</contact_no>

=back

=cut

__PACKAGE__->set_primary_key("contact_no");

=head1 RELATIONS

=head2 contact_phones

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::ContactPhone>

=cut

__PACKAGE__->has_many(
  "contact_phones",
  "Westerley::PoolManager::Schema::Result::ContactPhone",
  { "foreign.contact_no" => "self.contact_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 family_no

Type: belongs_to

Related object: L<Westerley::PoolManager::Schema::Result::Family>

=cut

__PACKAGE__->belongs_to(
  "family_no",
  "Westerley::PoolManager::Schema::Result::Family",
  { family_no => "family_no" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 passholder_contacts

Type: has_many

Related object: L<Westerley::PoolManager::Schema::Result::PassholderContact>

=cut

__PACKAGE__->has_many(
  "passholder_contacts",
  "Westerley::PoolManager::Schema::Result::PassholderContact",
  { "foreign.contact_no" => "self.contact_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-04 02:41:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HMXZQtl8CsvhNj2d/q2OQg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
