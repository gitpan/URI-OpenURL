print "1..1\n";

use strict;
use URI::OpenURL;

# Construct an OpenURL
my $uri = URI::OpenURL->new('http://openurl.ac.uk/');
$uri->referent(id => 'info:sid/dlib.org:dlib')->metadata('http://host/path/foobar_schema.ctx',
	foo=>'bar',
);

warn "\ntype=" . ref($uri) . " => " . $uri . "\n";

print "ok 1\n";
