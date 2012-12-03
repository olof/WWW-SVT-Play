#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::Trap;
use List::Util qw/max/;
use File::Slurp;
use JSON;
use Encode;
use lib 't/lib';

my @REF_FILES;
BEGIN { @REF_FILES = glob('t/data/ref/*.json') }

BEGIN {
	my $video_tests_n = 13; # n tests performed in video_tests() (recursive)
	plan tests => (1 + (@REF_FILES * $video_tests_n));
	use_ok('WWW::SVT::Play::Video')
}

sub get_number {
	my $f = shift;
	my ($n) = $f =~ m|([^/]+)\.json$|;
	return $n;
}

sub load_testdata {
	my %ref;
	my $json = JSON->new->utf8;

	for my $file (@REF_FILES) {
		my $n = get_number($file);
		my $data = read_file($file);
		$ref{$n} = $json->decode(encode('utf8', $data));
	}

	return %ref;
}

sub video_tests {
	my($n, $ref) = @_;
	note("Tests for $ref->{url} ($n)");

	my $svtp = new_ok('WWW::SVT::Play::Video', [$ref->{url}]);

	is($svtp->url, $ref->{ppurl}, '->url()');
	is($svtp->title, $ref->{title}, '->title()');
	is($svtp->duration, $ref->{duration}, '->duration()');

	SKIP: {
		skip 'Bitrate is only available when using RTMP', 2
			unless $svtp->has_rtmp;

		is_deeply(
			[sort {$a <=> $b } $svtp->rtmp_bitrates],
			[sort {$a <=> $b } keys %{$ref->{streams}->{rtmp}}],
			'->bitrates() in list context'
		);

		my $max = max $svtp->rtmp_bitrates;
		is(
			scalar $svtp->rtmp_bitrates,
			$max,
			'->bitrates() in scalar context'
		);
	}

	test_filename($ref, $svtp);

	is($svtp->duration, $ref->{duration}, '->duration()');

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
}

sub test_filename {
	my $ref = shift;
	my $svtp = shift;

	is($svtp->filename, $ref->{filename}, '->filename (no format)');

	is(
		$svtp->filename('rtmp'),
		"$ref->{filename}.rtmp",
		'filename method: called with type rtmp'
	);

	is(
		$svtp->filename('hds'),
		"$ref->{filename}.flv",
		'filename method: called with type hds'
	);

	is(
		$svtp->filename('hls'),
		"$ref->{filename}.mp4",
		'filename method: called with type hls'
	);

}

my %testcases = load_testdata();
for my $case (keys %testcases) {
	video_tests($case, $testcases{$case});
}
