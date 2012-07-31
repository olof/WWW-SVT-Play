package WWW::SVT::Play::Video;

# Copyright (c) 2012 - Olof Johansson <olof@cpan.org>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

=head1 NAME

WWW::SVT::Play::Video, extract information about videos on SVT Play

=head1 SYNOPSIS

 my $uri = 'http://www.svtplay.se/video/107889/malmopolisen-del-6';
 my $svtp = WWW::SVT::Play::Video->new($uri);
 say $svtp->title;

 my $max = 0;
 $max = $max < $_ ? $_ : $max for $svtp->bitrates;
 my $stream_uri = $svtp->uri($max);
 my $filename = $svtp->filename($max);
 
=head1 DESCRIPTION

=cut

use warnings FATAL => 'all';
use strict;

our $VERSION = 0.1;
use HTML::TreeBuilder;
use LWP::UserAgent;
use List::Util qw/max/;
use Encode;
use JSON;

=head1 CONSTRUCTOR

=head2 WWW::SVT::Play::Video->new($uri)

Construct a WWW::SVT::Play::Video object by passing the URL to
the video you're interested in. A second argument consisting of a
hashref of options is reserved for future use.

=cut

sub new {
	my $class = shift;
	my $uri = shift;

	$uri .= '?type=embed' unless $uri =~ /\?/;
	$uri .= '&type=embed' unless $uri =~ /[\&\?]type=/;
	my $html = _get($uri);
	my $json = _extract_json($html);
	
	my %bitrate = map {
		$_->{bitrate} => $_->{url}
	} @{$json->{video}->{videoReferences}};
	
	my @subtitles = map {
		$_->{url}
	} grep { $_->{url} } @{$json->{video}->{subtitleReferences}};

	bless {
		url => $uri,
		streams => \%bitrate,
		filename => $json->{statistics}->{title},
		subtitles => \@subtitles,
		duration => $json->{video}->{materialLength},
		title => $json->{context}->{title},
	}, $class;
}

=head2 url

 $svtp->url

Returns the URL after it has been postprocessed somewhat.

=cut

sub url {
	my $self = shift;
	return $self->{url};
}

=head2 stream

 $svtp->stream($bitrate)

Returns the stream URLs. If given a bitrate, only return a single
URL (for the specified bitrate). Returns undef if the bitrate
doesn't exist. When not given a bitrate, the URLs are returned in
as hash, keyed by the bitrate.

=cut

sub stream {
	my $self = shift;
	my $bitrate = shift;

	return $self->{streams}->{$bitrate} if $bitrate;
	return %{$self->{streams}};
}

=head2 title

Returns a human readable title for the video.

=cut

sub title {
	my $self = shift;
	return $self->{title};
}

=head2 $svtp->filename($bitrate)

Returns a filename suggestion for the video. If you give the
optional bitrate argument, you also get a file extension.

=cut

sub filename {
	my $self = shift;
	my $bitrate = shift;
	return $self->{filename} unless $bitrate;
	return $self->{filename} . '.' . $self->format($bitrate);
}

=head2 $svtp->bitrates

In list context, returns a list of available bitrates for the
video. In scalar context, the highest available bitrate is
returned. In either case, the returned values can be used as
argument to the module whenever a bitrate is asked for.

=cut

sub bitrates {
	my $self = shift;
	my @streams;
	@streams = keys %{$self->{streams}} if $self->{streams};
	return @streams if wantarray;
	return max(@streams);
}

=head2 $svtp->format($bitrate)

Returns a "guess" of what the format is, by trying to extract a
file extension from the stream URL. Of course, the format depends
on what bitrate you want, so you have to supply that.

=cut

sub format {
	my $self = shift;
	my $bitrate = shift;

	my ($ext) = $self->{streams}->{$bitrate} =~ m#\.([^/]+?)$#;
	return $ext;
}

=head2 $svtp->subtitles

In list context, returns a list of URLs to subtitles. In scalar
context, returns the first URL in that list. If there are no
subtitles available for this video, returns an empty list (in
list context) or undef (in scalar context).

=cut

sub subtitles {
	my $self = shift;
	my @subtitles;
	push @subtitles, @{$self->{subtitles}};

	return @subtitles if wantarray;
	return $subtitles[0];
}

=head2 $svtp->duration

Returns the length of the video in seconds.

=cut

sub duration {
	my $self = shift;
	return $self->{duration};
}

## INTERNAL SUBROUTINES
##  These are *not* easter eggs or something like that. Yes, I'm
##  looking at you, Woldrich!

sub _get {
	my $uri = shift;
	my $ua = LWP::UserAgent->new(
		agent => "WWW::SVT::Play/$VERSION",
	);
	$ua->env_proxy;
	my $resp = $ua->get($uri);
	
	return $resp->decoded_content if $resp->is_success;
	die "Failed to fetch $uri: ", $resp->status_line;
}

sub _extract_json {
	my $html = shift;
	my $tree = HTML::TreeBuilder->new_from_content($html);
	my $param = $tree->look_down(
		_tag => 'param',
		name => 'flashvars',
	);

	if($param and my($json) = $param->attr('value') =~ /^json=(.*)/) {
		# SVT claims it's utf-8, but it's not... not the json. at
		# least in one case it was iso-8859-15.
		my $jsonenc = encode('utf-8', decode('iso-8859-15', $json));
		return decode_json($jsonenc);
	}

	die "Could not find needed parameters from SVT Play";
}

=head1 COPYRIGHT

Copyright (c) 2012 - Olof Johansson <olof@cpan.org>
All rights reserved.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut

1;
