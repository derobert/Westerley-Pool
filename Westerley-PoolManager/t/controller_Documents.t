use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Westerley::PoolManager';
use Westerley::PoolManager::Controller::Documents;

ok( request('/documents')->is_success, 'Request should succeed' );
done_testing();
