#!/usr/bin/perl
# Copyright 2011, 2012, Olof Johansson <olof@ethup.se>
# Copyright 2011, Magnus Woldrich <magnus@trapd00r.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use vars qw($VERSION);
$VERSION = '0.3';
my $APP  = 'svtplay';

use strict;
use warnings;
use feature qw/say/;

use WWW::SVT::Play::Video;
use Getopt::Long qw/:config gnu_getopt/;
use Pod::Usage qw/pod2usage/;

sub usage {
	pod2usage(
		verbose  => 99,
		exitval  => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

usage() unless(@ARGV);

my $opts = {
	bitrate => 0,
	help => \&usage,
	version => sub { say("$APP v", __PACKAGE__->VERSION) && exit },
};
GetOptions($opts,
	'bitrate|b:i',
	'max-bitrate|m',
	'download|d',
	'output|o=s',
	'help|h',
	'version|v',
);

my $url = shift;
my $svtp = WWW::SVT::Play::Video->new($url) or
	die "Failed?";
my $bitrate = $opts->{bitrate};
$bitrate = $svtp->bitrates if $opts->{'max-bitrate'};

if($bitrate) {
	if($opts->{download}) {
		download($svtp, $bitrate);
	} else {
		say $svtp->url($bitrate);
	}
} else {
	say "W: You have to do specify a bitrate" if $opts->{download};
	say "$_: ", $svtp->url($_) for $svtp->bitrates;
}

exit 0;

sub download {
	my $svtp = shift;
	my $bitrate = shift;

	my $url = $svtp->url($bitrate);
	my $filename = $svtp->filename($bitrate);
	print "using filename $filename\n\n";
	exec("rtmpdump -r $url -o $filename");
}

__END__

=pod

=head1 NAME

svtplay - extract RTMP URLs from svtplay.se

=head1 DESCRIPTION

svtplay is a script that lets you extract RTMP URLs from SVT Play.
You can feed this URL to e.g. rtmpdump and extract the video using
options to the script.

=head1 SYNOPSIS

  svtplay [OPTIONS] <URL>

=head1 OPTIONS

  -d, --download     download video
  -b, --bitrate      choose bitrate. only list available bitrates if omitted
  -m, --max-bitrate  choose the best available bitrate
  -o, --output file  specify output filename

  -h, --help         show the help and exit
  -v, --version      show version info and exit

=head1 CONTRIBUTORS

=over

=item Magnus Woldrich, magnus@trapd00r.se, http://japh.se, trapd00r on github

=back

=head1 COPYRIGHT

Copyright 2011, Olof Johansson <olof@ethup.se>
(and contributors...)

Copying and distribution of this file, with or without
modification, are permitted in any medium without royalty
provided the copyright notice are preserved. This file is
offered as-is, without any warranty.
