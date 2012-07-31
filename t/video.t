#!/usr/bin/perl
use warnings;
use strict;
use Test::More tests => 27;
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
		$ref->{subtitles},
		'->subtitles() in list context (no subs)'
	);
	is(
		$svtp->subtitles,
		$ref->{subtitles}->[0],
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
	subtitles => [],
});

video_tests({
	url => 'http://www.svtplay.se/video/198930/del-8-av-12-the-astonishing',
	title => 'Del 8 av 12: The Astonishing',
	bitrates => [qw/320 340 364 850 1400 2400/],
	duration => 1705,
	streams => {
		320 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-b-v1-9f4b2046d497059e.mp4',
		},
		340 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'rtsp://rtsp0.91001-od0.dna.qbrick.com/91001-od0/mp4:_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-a-v1-9f4b2046d497059e.mp4',
		},
		364 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'http://geoip.api.qbrick.com/services/rest/qticket/svtplay.aspx?vurl=mms://secure-wm.qbrick.com/91001/wp3/1170726/NURSE_JACKIE_3-008A-wmv-a-v1-9f4b2046d497059e.wmv',
		},
		850 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-c-v1-9f4b2046d497059e.mp4',
		},
		1400 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-d-v1-9f4b2046d497059e.mp4',
		},
		2400 => {
			filename => 'del-8-av-12-the-astonishing.mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-e-v1-9f4b2046d497059e.mp4'
		},
	},

	subtitles => [
		'http://media.svt.se/download/mcc/wp3/undertexter-wsrt/1170726/EPISOD-1170726-008A-wsrt-9f4b2046d497059e.wsrt'
	],
});

