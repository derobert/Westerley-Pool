package Westerley::PoolManager::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config({
		CATALYST_VAR => 'C',
		INCLUDE_PATH => [
			Westerley::PoolManager->path_to('root', 'src'),
			Westerley::PoolManager->path_to('root', 'lib')
		],
		PRE_PROCESS        => 'config/main',
		WRAPPER            => 'site/wrapper',
		ENCODING           => 'utf-8',
		ERROR              => 'error.tt2',
		TEMPLATE_EXTENSION => '.tt2',
		TIMER              => 0,
		render_die         => 1,
	});

=head1 NAME

Westerley::PoolManager::View::TT - Catalyst TTSite View

=head1 DESCRIPTION

TT View for Westerley::PoolManager.

=head1 SEE ALSO

L<Westerley::PoolManager>

=head1 AUTHOR

Anthony DeRobertis

=head1 LICENSE

Copyright (C) 2014  Anthony DeRobertis <anthony@derobert.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
