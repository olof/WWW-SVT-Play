#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile (
	NAME => 'WWW::SVT::Play',
	AUTHOR => 'Olof Johansson <olof@cpan.org>',
	LICENSE => 'perl',
	ABSTRACT_FROM => 'lib/WWW/SVT/Play.pm',
	VERSION_FROM => 'lib/WWW/SVT/Play.pm',
	SIGN => 1,

	PREREQ_PM => {
		'LWP::UserAgent' => 0,
		'JSON' => 0,
		'HTML::Entities' => 0,
		'HTML::TreeBuilder' => 0,
	},
);

