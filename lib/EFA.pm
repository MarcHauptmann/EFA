package EFA;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(get_departures departures_from_xml);

$VERSION = "0.0.1";

use EFA::Departure;
use EFA::Utils;
use XML::XPath;
use LWP::UserAgent;
use utf8;
use strict;
use warnings;

sub get_departures {
  my $station_id = $_[0];
  my $ua = LWP::UserAgent->new();

  my $response = $ua->get("http://mobil.efa.de/mobile3/XSLT_DM_REQUEST?maxAssignedStops=1&mode=direct&limit=10&name_dm=$station_id&type_dm=stopID&outputFormat=xml");

  my $xml = $response->content();

  return departures_from_xml($xml);
}

sub get_value {
  my ($path, $node) = @_;

  my @nodes = $node->findnodes($path);

  if (scalar(@nodes) > 0) {
    return $nodes[0]->getNodeValue();
  } else {
    return undef;
  }
}

sub departures_from_xml {
  my $xml = $_[0];

  my @result = ();
  my $xp = XML::XPath->new(xml => $xml);

  my @nodeset = $xp->findnodes("//itdDeparture");

  foreach my $node (@nodeset) {
    my $departure = EFA::Departure->new();

    my $time = DateTime->new(year => get_value("itdDateTime/itdDate/\@year", $node),
                             month => get_value("itdDateTime/itdDate/\@month", $node),
                             day => get_value("itdDateTime/itdDate/\@day", $node),
                             hour => get_value("itdDateTime/itdTime/\@hour", $node),
                             minute => get_value("itdDateTime/itdTime/\@minute", $node));

    $departure->set_line(get_value("itdServingLine/\@symbol", $node));
    $departure->set_destination(get_value("itdServingLine/\@direction", $node));
    $departure->set_time($time);

    push @result, $departure;
  }

  return @result;
}

1;

