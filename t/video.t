#!/usr/bin/perl
use warnings;
use strict;
use Test::More tests => 10;
use lib 't/lib';
use List::Util qw/max/;

my $ref = {
	url => 'http://www.svtplay.se/video/188402/14-7-21-00',
	title => '14/7 21:00',
	bitrates => [qw/320 850 1400/],
	duration => 5371,
	filename => {
		320 => '14-7-21-00.mp4',
		850 => '14-7-21-00.mp4',
		1400 => '14-7-21-00.mp4',
	},
};

sub fileext {
	my $_ = shift;
	s/.*\.//;
	return $_;
}

BEGIN { use_ok('WWW::SVT::Play::Video') }

my $svtp = new_ok('WWW::SVT::Play::Video', [$ref->{url}]);
is($svtp->url, "$ref->{url}?type=embed", '->url()');
is($svtp->title, $ref->{title}, '->title()');
is($svtp->duration, 5371, '->duration()');

is_deeply(
	[sort {$a <=> $b } $svtp->bitrates],
	$ref->{bitrates},
	'->bitrates() in list context'
);

my $max = max $svtp->bitrates;
is(scalar $svtp->bitrates, $max, '->bitrates() in scalar context');
is($svtp->filename($max), $ref->{filename}->{$max}, '->filename()');
is($svtp->format($max), fileext($ref->{filename}->{$max}), '->format()');
is($svtp->duration, $ref->{duration}, '->duration()');
