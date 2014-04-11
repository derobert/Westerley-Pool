use utf8;
package Westerley::PoolManager::Schema::ResultSet::Passholder;

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

__PACKAGE__->load_components('Helper::ResultSet::AutoRemoveColumns');
__PACKAGE__->meta->make_immutable;
1;
