package URI::OpenURL;

=pod

=head1 NAME

URI::OpenURL - Parse and construct OpenURL's (NISO Z39.88-2004)

=head1 DESCRIPTION

This module provides an implementation of OpenURLs encoded as URIs (Key/Encoded-Value (KEV) Format), this forms only a part of the OpenURL spec. It does not check that OpenURLs constructed are sane according to the OpenURL specification (to a large extent sanity will depend on the community of use).

From the implementation guidelines:

The description of a referenced resource, and the descriptions of the associated resources that comprise the context of the reference, bundled together are called a ContextObject. It is a ContextObject that is transported when a user makes a request by clicking a link. A KEV OpenURL may contain only one ContextObject.

The ContextObject may contain up to six Entities. One of these, the Referent, conveys information about the referenced item. It must always be included in a ContextObject. The other five entities - ReferringEntity, Requester, Resolver, ServiceType and Referrer - hold information about the context of the reference and are optional.

= OpenURL

http://library.caltech.edu/openurl/

From the implementation guidelines:

The OpenURL Framework for Context-Sensitive Services Standard provides a means of describing a referenced resource along with a description of the context of the reference.  Additionally it defines methods of transporting these descriptions between networked systems. It is anticipated that it will be used to request services pertaining to the referenced resource and appropriate for the requester.

The OpenURL Framework is very general and has the potential to be used in many application domains and by many communities. Concrete instantiations of the various core components within the framework are defined within the OpenURL Registry. The OpenURL Framework is currently a .draft standard for ballot.. During the ballot and public review period, the content of the Registry will be static and has been pre-defined by the NISO AX Committee. There is also an experimental registry where components under development are held. In the future it will be possible to register further items.

There are currently two formats for ContextObjects defined in the OpenURL Framework, Key/Encoded-Value and XML. This document provides implementation guidelines for the Key/Encoded-Value Format, concentrating mainly, but not exclusively, on components from the San Antonio Level 1 Community Profile (SAP1).

=head1 SYNOPSIS

	use URI::OpenURL;

	# Construct an OpenURL
	# This is the first example from the implementation specs,
	# with additional resolver and serviceType entities.
	print URI::OpenURL->new('http://other.service/cgi/openURL'
		)->referrer(
			id => 'info:sid/my.service',
		)->requester(
			id => 'mailto:john@invalid.domain',
		)->resolver(
			id => 'info:sid/other.service',
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
		)->as_string();

	# Parsing (wrappers for $uri->query_form())
	my $uri = URI::OpenURL->new('http://a.openurl/?url_ver=Z39.88-2004&...');
	my @referent = $uri->referent->metadata();
	print join(',',@referent), "\n";
	# This could lose data if there is more than one id
	my %ds = $uri->referent->descriptors();
	if( !exists($ds{val_fmt}) ) {
		warn "No by-value metadata for referent in OpenURL";
	} elsif($ds{val_fmt} eq 'info:ofi/fmt:kev:mtx:journal') {
		my %md = $uri->referent->metadata();
		print ($md{genre} || 'Unknown journal article genre'), "\n";
	}

=head1 METHODS

=over 4

=cut

use vars qw( $VERSION );

$VERSION = '0.2';

use strict;
use URI::Escape;
use Carp;
use POSIX qw/ strftime /;

require URI::_server;
use vars qw( @ISA );
@ISA = qw( URI::http );

=pod

=item $uri = URI::openurl->new([$url])

Create a new URI::openurl object and optionally initialize with $url. If $url does not contain a query component (...?key=value) the object will be initialized to a valid contextobject, but without any entities.

=cut

sub new {
	_init(@_);
}

sub _init {
	my $self = shift->SUPER::_init(@_);
	$self->query_form(
		ctx_ver => 'Z39.88-2004',
		ctx_enc => 'info:ofi/enc:UTF-8',
		ctx_id => '1', # TODO Check whether ctx_id is significant for URIs
		ctx_tim => strftime("%Y-%m-%dT%H:%M:%STZD",gmtime(time)),
		url_ver => 'Z39.88-2004',
		url_tim => strftime("%Y-%m-%dT%H:%M:%STZD",gmtime(time)),
		url_ctx_fmt => 'info:ofi/fmt:kev:mtx:ctx',
	) unless $self->query_form();
	$self;
}

=pod

=item $uri = $uri->referent()

Every ContextObject must have a Referent, the referenced resource for which the ContextObject is created. Within the scholarly information community the Referent will probably be a document-like object, for instance: a book or part of a book; a journal publication or part of a journal; a report; etc.

=cut

sub referent {
	my $self = bless shift, 'OpenURL::referent';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=pod

=item $uri->referringEntity()

The ReferringEntity is the Entity that references the Referent. It is optional in the ContextObject. Within the scholarly information community the ReferringEntity could be a journal article that cites the Referent. Or it could be a record within an abstracting and indexing database.

=cut

sub referringEntity {
	my $self = bless shift, 'OpenURL::referringEntity';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=pod

=item $uri = $uri->requester()

The Requester is the Entity that requests services pertaining to the Referent. It is optional in the ContextObject. Within the scholarly information community the Requester is generally a human end-user who clicks a link within a digital library application.

=cut

sub requester {
	my $self = bless shift, 'OpenURL::requester';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=item $uri = $uri->serviceType()

The ServiceType is the Entity that defines the type of service requested. It is optional in the ContextObject. Within the scholarly information community the ServiceType could be a request for; the full text of an article; the abstract of an article; an inter-library loan request, etc.

=cut

sub serviceType {
	my $self = bless shift, 'OpenURL::serviceType';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=pod

=item $uri = $uri->resolver()

The Resolver is the Entity at which a request for services is targeted. It is optional in the ContextObject. This need not be the same Resolver as that specified as the base URL for an OpenURL Transport and does not replace that base URL.

=cut

sub resolver {
	my $self = bless shift, 'OpenURL::resolver';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=pod

=item $uri = $uri->referrer()

The Referrer is the Entity that generated the ContextObject. It is optional in the ContextObject, but its inclusion is strongly encouraged. Within the scholarly information community the Referrer will be an information provider such as an electronic journal application or an 'abstracting and indexing' service.

=cut

sub referrer {
	my $self = bless shift, 'OpenURL::referrer';
	return $self->descriptors() if wantarray;
	$self->_addattr(@_);
}

=pod

=item $uri = $uri->referent->dublinCore(key => value)

=item $uri = $uri->referent->book(key => value)

=item $uri = $uri->referent->dissertation(key => value)

=item $uri = $uri->referent->journal(key => value)

=item $uri = $uri->referent->patent(key => value)

=item $uri = $uri->serviceType->scholarlyService(key => value)

Add metadata to the current entity (referent is given only as an example). Dublin Core is an experimental format.

=item @descs = $uri->referent->descriptors([$key=>$value[, $key=>$value]])

Return the descriptors as a list of key-value pairs for the current entity (referent is given as an example).

Optionally add descriptors (functionally equivalent to $uri->referent($key=>$value)).

=item @metadata = $uri->referent->metadata([$schema_url, $key=>$value[, $key=>$value]])

Returns by-value metadata as a list of key-value pairs for the current entity (referent is given as an example).

Optionally, if you wish to add metadata that does not use one of the standard schemas (journal, book etc.) then you can add them using metadata.

=head1 ABOUT

This module should be considered BETA, not least because the OpenURL standard is (as of 2004-05-12) "submitted to NISO for Ballot". However it is not intended to change the interface.

=head1 TODO

"Easy" access to descriptors and metadata, e.g. $uri->referent->descriptor->id().

=head1 NOTES

This module works a little differently to the other URI modules in that structured data is added by calling methods that return an object. Whenever an entity method is called the object gets casted into a class encapsulating that entity, allowing further method calls to add metadata. The net result of this is that the URI object will change type as you add data to the object.

The reason for doing this is URI only allows one value to be stored (the URI string), so to keep the context of which entity the user is adding data to the only thing I could think of was to change the class. The downside of this is you can't use URI::openurl as a superclass.

You will also notice that if you try creating an URI object with an OpenURL (which is actually http:) the http module will be called rather than openurl. You can either call openurl directly as given in the synopsis, or by changing 'http' to 'openurl', in which case URI will call the correct module.

=head1 COPYRIGHT

Quotes from the OpenURL implementation guidelines are from: http://library.caltech.edu/openurl/

Copyright 2004 Tim Brody.

This module is released under the same terms as the main Perl distribution.

=head1 AUTHOR

Tim Brody <tdb01r@ecs.soton.ac.uk>
Intelligence, Agents, Multimedia Group
University of Southampton, UK

=back

=cut

package OpenURL::entity;

use vars qw(@ISA);
@ISA = qw(URI::OpenURL);

use vars qw( %ENTITIES );

%ENTITIES = (
	referent 	=> 	'rft',
	referringEntity => 	'rfe',
	serviceType	=>	'svc',
	requester	=>	'req',
	resolver	=>	'res',
	referrer 	=> 	'rfr',
);

sub _entity {
	my $entity = ref(shift());
	$entity =~ s/.*:://;
	$ENTITIES{$entity};
}

sub _addattr {
	my ($self,@pairs) = @_;
	my @KEVS = $self->query_form();
	my $entity = _entity($self);
	for( my $i = 0; $i < @pairs; $i+=2 ) {
		push @KEVS, $entity.'_'.$pairs[$i], ($pairs[$i+1]||'');
	}
	$self->query_form(@KEVS);
	$self;
}

sub _addkevs {
	my ($self,$val_fmt,@pairs) = @_;
	my @KEVS = $self->query_form();
	my $entity = _entity($self);
	push @KEVS, $entity.'_val_fmt', $val_fmt if $val_fmt;
	for( my $i = 0; $i < @pairs; $i+=2 ) {
		#	if( $pairs[$i] =~ /^id|val_fmt|ref_fmt|ref|dat$/ ) {
		push @KEVS, $entity.'.'.$pairs[$i], ($pairs[$i+1]||'');
	}
	$self->query_form(@KEVS);
	bless $self, 'URI::openurl'; # Should catch some broken user code
}

sub descriptor {
	my ($self,$key) = @_;
	my @KEVS = $self->query_form();
	my @VALS;
	my $entity = $self->_entity();
	for(my $i = 0; $i < @KEVS; $i+=2) {
		push @VALS, $KEVS[$i+1] if( $KEVS[$i] eq "${entity}_${key}" );
	}
	@VALS;
}

sub dublinCore {
	shift->_addkevs('info:ofi/fmt:kev:mtx:dc',@_);
}

sub book {
	shift->_addkevs('info:ofi/fmt:kev:mtx:book',@_);
}

sub dissertation {
	shift->_addkevs('info:ofi/fmt:kev:mtx:dissertation',@_);
}

sub journal {
	shift->_addkevs('info:ofi/fmt:kev:mtx:journal',@_);
}

sub patent {
	shift->_addkevs('info:ofi/fmt:kev:mtx:patent',@_);
}

sub scholarlyService {
	shift->_addkevs('info:ofi/fmt:kev:mtx:sch_svc',@_);
}

# Descriptors (things with '_' in)
sub descriptors {
	my $self = shift;
	$self->_addattr(@_) if @_;
	return () unless wantarray;
	my $entity = $self->_entity();
	my @pairs = $self->query_form();
	my @md;
	for(my $i = 0; $i < @pairs; $i+=2) {
		if( $pairs[$i] =~ s/^$entity\_// ) {
			push @md, $pairs[$i], $pairs[$i+1];
		}
	}
	return @md;
}

# By-value metadata (things with '.' in)
sub metadata {
	my $self = shift;
	$self->_addkevs(@_) if @_;
	return () unless wantarray;
	my $entity = $self->_entity();
	my @pairs = $self->query_form();
	my @md;
	for(my $i = 0; $i < @pairs; $i+=2) {
		if( $pairs[$i] =~ s/^$entity\.// ) {
			push @md, $pairs[$i], $pairs[$i+1];
		}
	}
	return @md;
}

package OpenURL::referent;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

package OpenURL::referringEntity;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

package OpenURL::requester;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

package OpenURL::serviceType;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

package OpenURL::resolver;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

package OpenURL::referrer;

use vars qw(@ISA);
@ISA = qw(OpenURL::entity);

1;

