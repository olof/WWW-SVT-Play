#!/usr/bin/perl
use 5.014;
use warnings FATAL => 'all';
use HTML::TreeBuilder;
use Encode;
use JSON;
use Data::Dumper;
use Getopt::Long;
use URI;
use URI::Escape;
use LWP::Simple;
$Data::Dumper::Indent = 1;

my $dumper;
GetOptions(
	'dumper'   => \$dumper,
);

sub download {
	my $url = shift;
	my $dest = shift;

	my $data = get($url) or die("Could not download $url");

	open my $fh, '>', $dest or die("Could not open $dest: $!");
	print $fh $data;
	say "Wrote HTML to $dest";
}

sub process_url {
	my $url = shift;

	$url =~ s/type=\K[^&]*/embed/;
	$url .= '&type=embed' if     $url =~ /\?/;
	$url .= '?type=embed' unless $url =~ /\?/;

	return $url;
}

sub dump_json {
	my $n = shift;
	my $data = shift;

	open my $fh, '>', "ref/$n.json" or die "Could not open ref/$n.json: $!";
	my $json = JSON->new->allow_nonref;
	say $fh $json->pretty->encode($data);
	close $fh;
	say "Wrote JSON to ref/$n.json";
}


my $url = shift or die("Need url\n");
my ($n) = $url =~ m|/video/([0-9]+)/[^/]+$| or die "URL does not match";
my $ppurl = process_url($url);
my $file = "$n.html";
download($ppurl, $file);
my $tree = HTML::TreeBuilder->new_from_file($file);

my $param = $tree->look_down(
	_tag => 'param',
	name => 'flashvars',
) or die "Could not find needed parameters from SVT Play";

my($jsonblob) = $param->attr('value') =~ /^json=(.*)/ or
	die "Could not find needed JSON object";

my $jsonenc = encode('utf-8', decode('iso-8859-15', $jsonblob));
my $data = decode_json($jsonenc);

if ($dumper) {
	say Dumper $data;
	exit 0;
}
# Otherwise, prepare the data for the test format.

my $output;

$output->{url} = $url;
$output->{ppurl} = $ppurl;

$output->{duration} = $data->{video}->{materialLength};
$output->{subtitles} = [map {
	values $_
} @{$data->{video}->{subtitleReferences}}];
$output->{title} = $data->{context}->{title};
$output->{filename} = uri_unescape(
	URI->new($data->{statistics}->{statisticsUrl})->query
);

$output->{streams} = [map {
	#say Dumper $_;
	my $plt = $_->{playerType};
	my $btr = $_->{bitrate};
	my $url = $_->{url};
	my $out;

	$out = $plt eq 'flash' && $btr == 0 ?
		{ type => 'hds' } :
	$plt eq 'flash' ? 
		{ type => 'rtmp', bitrate => $btr } :
	$plt eq 'ios' ?
		{ type => 'hls' } :
		{ type => $plt };
	$out->{url} = $url;
	$out;
} @{$data->{video}->{videoReferences}}];

dump_json($n, $output);
