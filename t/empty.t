print "1..1\n";

use strict;
use URI::OpenURL;

# Construct an OpenURL
my $uri = URI::OpenURL->new('http://openurl.ac.uk/');

warn "\ntype=" . ref($uri) . " => " . $uri . "\n";

print "ok 1\n";
