print "1..1\n";

use strict;
use URI::openurl;

# Construct an OpenURL
my $uri = URI->new("openurl://citebase.eprints.org/cgi-bin/openurl"
	)->referrer(id => 'info:sid/dlib.org:dlib',
	)->requester(id => 'mailto:tdb01r@ecs.soton.ac.uk',
	)->resolver(id => 'http://citebase.eprints.org/',
	)->serviceType()->scholarlyService(
		fulltext => 'yes',
	)->referringEntity(id => 'info:doi/10.1045/march2001-vandesompel')->journal(
		genre => 'article',
		aulast => 'Van de Sompel',
		aufirst => 'Herbert',
		issn => '1082-9873',
		volume => '7',
		issue => '3',
		date => '2001',
		atitle => 'Open Linking in the Scholarly Information Environment using the OpenURL Framework',
	)->referent(id => 'info:doi/10.1045/july99-caplan')->journal(
		genre => 'article',
		aulast => 'Caplan',
		aufirst => 'Priscilla',
		issn => '1082-9873',
		volume => '5',
		issue => '7/8',
		date => '1999',
		atitle => 'Reference Linking for Journal Articles',
	);

warn "\ntype=" . ref($uri) . " => " . $uri . "\n";

print "ok 1\n";
