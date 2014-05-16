use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/lib/";
use Westerley::PoolManager;

my $app = Westerley::PoolManager->apply_default_middlewares(Westerley::PoolManager->psgi_app);
$app;

