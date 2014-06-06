use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Westerley::PoolManager';
use Westerley::PoolManager::Controller::Backup;

ok( request('/backup')->is_success, 'Request should succeed' );
done_testing();
