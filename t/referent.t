print "1..1\n";

use strict;
use URI::openurl;

# Construct an OpenURL
my $uri = URI->new('openurl://citebase.eprints.org/cgi-bin/openURL');
$uri->referent(id => 'info:sid/dlib.org:dlib')->journal(
	genre=>'article',
	title=>'J.CHEM.PHYS.',
);

warn "\ntype=" . ref($uri) . " => " . $uri . "\n";

print "ok 1\n";
