use strict;
use Test;

BEGIN { plan tests => 1 }

use URI::OpenURL;

# Construct an OpenURL
my $uri = URI::OpenURL->new('http://openurl.ac.uk/');
$uri->referent(id => 'info:sid/dlib.org:dlib')->metadata('http://host/path/foobar_schema.ctx',
	foo=>'bar',
);

ok($uri,'http://openurl.ac.uk/?ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&rft_id=info%3Asid%2Fdlib.org%3Adlib&rft_val_fmt=http%3A%2F%2Fhost%2Fpath%2Ffoobar_schema.ctx&rft.foo=bar');
