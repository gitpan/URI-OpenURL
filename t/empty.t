print "1..1\n";

use strict;
use URI::openurl;

# Construct an OpenURL
my $uri = URI::openurl->new('http://citebase.eprints.org/cgi-bin/openURL');

warn "\ntype=" . ref($uri) . " => " . $uri . "\n";

print "ok 1\n";
