#!/usr/bin/perl
use warnings;
use strict;
use Test::More tests => 14;
use lib 't/lib';
use List::Util qw/max/;

BEGIN { use_ok('WWW::SVT::Play::Video') }

my $URIBASE = 'rtmp://fl11.c91005.cdn.qbrick.com';

sub video_tests {
	my($ref) = @_;
	note("Tests for $ref->{url}");

	my $svtp = new_ok('WWW::SVT::Play::Video', [$ref->{url}]);

	is($svtp->url, "$ref->{url}?type=embed", '->url()');
	is($svtp->title, $ref->{title}, '->title()');
	is($svtp->duration, $ref->{duration}, '->duration()');

	is_deeply(
		[sort {$a <=> $b } $svtp->bitrates],
		$ref->{bitrates},
		'->bitrates() in list context'
	);

	my $max = max $svtp->bitrates;
	is(scalar $svtp->bitrates, $max, '->bitrates() in scalar context');

	is(
		$svtp->filename($max),
		$ref->{streams}->{$max}->{filename},
		'->filename()'
	);

	is($svtp->format($max), fileext($ref->{streams}->{$max}), '->format()');
	is($svtp->duration, $ref->{duration}, '->duration()');
	is(
		$svtp->stream($max),
		$ref->{streams}->{$max}->{uri},
		"->stream($max)"
	);

	# The trivial case where no subtitle is available
	is_deeply(
		[$svtp->subtitles],
		[],
		'->subtitles() in list context (no subs)'
	);
	is(
		$svtp->subtitles,
		undef,
		'->subtitles() in scalar context (no subs)'
	);

	is_deeply(
		{ $svtp->stream() },

		# Transform internal ref format to look like
		# the output of the module
		{ map {
			$_ => $ref->{streams}->{$_}->{uri}
		} keys %{$ref->{streams}} },

		'->stream() in list context'
	);
}

sub fileext {
	my $_ = shift;
	$_ = $_->{filename};
	s/.*\.//;
	return $_;
}

video_tests({
	url => 'http://www.svtplay.se/video/188402/14-7-21-00',
	title => '14/7 21:00',
	bitrates => [qw/320 850 1400/],
	duration => 5371,
	streams => {
		320 => {
			filename => '14-7-21-00.mp4',
			uri => "$URIBASE/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-b-v1-04b3eee6620d4385.mp4",
		},
		850 => {
			filename => '14-7-21-00.mp4',
			uri => "$URIBASE/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-c-v1-04b3eee6620d4385.mp4",
		},
		1400 => {
			filename => '14-7-21-00.mp4',
			uri => "$URIBASE/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-d-v1-04b3eee6620d4385.mp4",
		},
	},
});

