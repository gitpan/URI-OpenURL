print "1..1\n";

use strict;
use URI::OpenURL;

my $test = <<EOF;
http://openurl.ac.uk/?url_ver=Z39.88-2004&url_tim=2003-04-10T13%3A57%3A15TZD&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx &ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_id=10_1&ctx_tim=2003-04-10T13%3A56%3A30TZD&rft_id=info%3Adoi%2F10.1045%2Fjuly99-caplan&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article&rft.aulast=Caplan&rft.aufirst=Priscilla&rft.issn=1082-9873&rft.volume=5&rft.issue=7/8&rft.date=1999&rft.atitle=Reference+Linking+for+Journal+Articles&rfe_id=info%3Adoi%2F10.1045%2Fmarch2001-vandesompel&rfe_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rfe.genre=article&rfe.aulast=Van+de+Sompel&rfe.aufirst=Herbert&rfe.issn=1082-9873&rfe.volume=7&rfe.issue=3&rfe.date=2001&rfe.atitle=Open+Linking+in+the+Scholarly+Information+Environment+using+the+OpenURL+Framework&rfr_id=info%3Asid%2Fdlib.org%3Adlib
EOF

# Construct an OpenURL
my $uri = URI::OpenURL->new($test);

my @pairs = $uri->referent; # Shorthand for $uri->referent->descriptors()
warn "\n";
for(my $i = 0; $i < @pairs; $i+=2) {
	warn $pairs[$i] . " => ".$pairs[$i+1] . "\n";
}

@pairs = $uri->referent->metadata();
warn "\n";
for(my $i = 0; $i < @pairs; $i+=2) {
	warn $pairs[$i] . " => ".$pairs[$i+1] . "\n";
}

print "ok 1\n";
