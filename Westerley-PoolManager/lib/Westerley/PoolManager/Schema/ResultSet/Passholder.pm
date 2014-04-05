use utf8;
package Westerley::PoolManager::Schema::ResultSet::Passholder;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
__PACKAGE__->load_components('Helper::ResultSet::AutoRemoveColumns');

1;
