print "1..1\n";

use strict;
use URI;

    my $uri = new URI();
    $uri->scheme('OpenURL');
    $uri->host('openurl.ac.uk');
    $uri->path('/');
    $uri->referent(id => 'info:doi/10.1045/july99-caplan')->journal(genre=>'article');
	$uri->scheme('http');
    warn $uri, "\n";

print "ok 1\n";
