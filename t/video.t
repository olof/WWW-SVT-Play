#!/usr/bin/perl
use warnings;
use strict;
use Test::More tests => 5;
use lib 't/lib';

my $ref = {
	url => 'http://www.svtplay.se/video/188402/14-7-21-00',
	title => '14/7 21:00',
};

BEGIN { use_ok('WWW::SVT::Play::Video') }

my $svtp = new_ok('WWW::SVT::Play::Video', [$ref->{url}]);
is($svtp->url, "$ref->{url}?type=embed", '->url()');
is($svtp->title, $ref->{title}, '->title()');
is($svtp->duration, 5371, '->duration()');
