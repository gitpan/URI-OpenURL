use Test;
use strict;

BEGIN { plan tests => 5 }

use URI::OpenURL;
use POSIX qw/strftime/;

# Construct an OpenURL
my $uri = URI::OpenURL->new('http://openurl.ac.uk/');
ok($uri,'http://openurl.ac.uk/?ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx');

my $ttime = strftime("%Y-%m-%dT%H:%M:%STZD",gmtime(1107434304));
ok(!defined($uri->init_timestamps($ttime)));
my %query = $uri->query_form;
ok(
	$query{'ctx_ver'} eq 'Z39.88-2004' &&
	$query{'ctx_tim'} eq $ttime && $query{'url_tim'} eq $ttime
);
ok($uri->init_timestamps,$ttime);
ok($uri->init_timestamps ne $ttime);
