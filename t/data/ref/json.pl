use JSON;
use warnings;
use strict;
use 5.014;

sub get_name {
	my $url = shift;
	my ($n) = $url =~ m|/video/([0-9]+)/|;
	return $n;
}

my @ref;

push @ref, {
	url => 'http://www.svtplay.se/video/188402/14-7-21-00',
	ppurl => 'http://www.svtplay.se/video/188402/14-7-21-00?type=embed',
	title => '14/7 21:00',
	filename => 'svt-play.kultur-och-nöje.grattis-kronprinsessan-.hela-program.14-7-21-00',
	bitrates => [qw/320 850 1400/],
	duration => 5371,
	streams => {
		rtmp => {
			320 => {
				fileext => 'mp4',
				uri => "rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-b-v1-04b3eee6620d4385.mp4",
			},
			850 => {
				fileext => 'mp4',
				uri => "rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-c-v1-04b3eee6620d4385.mp4",
			},
			1400 => {
				fileext => 'mp4',
				uri => "rtmp://fl11.c91005.cdn.qbrick.com/91005/_definst_/wp3/1240377/GRATTIS_VICTORI-001A-mp4-d-v1-04b3eee6620d4385.mp4",
			},
		}
	},
	subtitles => [],
};

push @ref, {
	url => 'http://www.svtplay.se/video/198930/del-8-av-12-the-astonishing',
	ppurl => 'http://www.svtplay.se/video/198930/del-8-av-12-the-astonishing?type=embed',
	title => 'Del 8 av 12: The Astonishing',
	filename => 'svt-play.film-och-drama.nurse-jackie.hela-program.del-8-av-12-the-astonishing',
	bitrates => [qw/320 340 364 850 1400 2400/],
	duration => 1705,
	streams => {
		320 => {
			fileext => 'mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-b-v1-9f4b2046d497059e.mp4',
		},
		340 => {
			fileext => 'mp4',
			uri => 'rtsp://rtsp0.91001-od0.dna.qbrick.com/91001-od0/mp4:_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-a-v1-9f4b2046d497059e.mp4',
		},
		364 => {
			fileext => 'mp4',
			uri => 'http://geoip.api.qbrick.com/services/rest/qticket/svtplay.aspx?vurl=mms://secure-wm.qbrick.com/91001/wp3/1170726/NURSE_JACKIE_3-008A-wmv-a-v1-9f4b2046d497059e.wmv',
		},
		850 => {
			fileext => 'mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-c-v1-9f4b2046d497059e.mp4',
		},
		1400 => {
			fileext => 'mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-d-v1-9f4b2046d497059e.mp4',
		},
		2400 => {
			fileext => 'mp4',
			uri => 'rtmpe://fl11.c90909.cdn.qbrick.com/90909/_definst_/wp3/1170726/NURSE_JACKIE_3-008A-mp4-e-v1-9f4b2046d497059e.mp4'
		},
	},

	subtitles => [
		'http://media.svt.se/download/mcc/wp3/undertexter-wsrt/1170726/EPISOD-1170726-008A-wsrt-9f4b2046d497059e.wsrt'
	],
};

my $json = JSON->new->allow_nonref;

for (@ref) {
	my $n = get_name($_->{url});

	open my $fh, '>', "./$n.json" or die("$!");
	print $fh $json->pretty->encode($_);
	close $fh;
}

