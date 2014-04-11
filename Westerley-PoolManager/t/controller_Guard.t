use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Westerley::PoolManager';
use Westerley::PoolManager::Controller::Guard;

ok( request('/guard')->is_success, 'Request should succeed' );
done_testing();
