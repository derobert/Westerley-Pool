use strict;
use warnings;

use lib 'lib/';
use Westerley::PoolManager;

my $app = Westerley::PoolManager->apply_default_middlewares(Westerley::PoolManager->psgi_app);
$app;

