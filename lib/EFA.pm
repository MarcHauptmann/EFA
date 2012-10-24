package EFA;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(get_departures departures_from_xml stations_from_xml find_station);

$VERSION = "0.0.1";

use EFA::Departure;
use EFA::Utils;
use XML::XPath;
use LWP::UserAgent;
use DateTime;
use utf8;
use strict;
use warnings;
use Encode;

sub get_departures {
  my ($station_id, %values) = @_;
  my $ua = LWP::UserAgent->new();

  my $num = 5;

  if ($values{"num"}) {
    $num = $values{"num"};
  }

  my $time = DateTime->now(time_zone => "local");

  if ($values{"time"}) {
    $time = $values{"time"};
  }

  my $url = "http://mobil.efa.de/mobile3/XSLT_DM_REQUEST?maxAssignedStops=1";

  $url .= "&outputFormat=xml";
  $url .= "&mode=direct";
  $url .= "&name_dm=$station_id";
  $url .= "&limit=$num";
  $url .= "&type_dm=stopID";
  $url .= "&itdTimeHour=".$time->hour;
  $url .= "&itdTimeMinute=".$time->minute;
  $url .= "&itdDate=".$time->year.$time->month.$time->day;

  my $response = $ua->get($url);

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

sub find_station {
  my $query = $_[0];
  my $ua = LWP::UserAgent->new();

  my $response = $ua->get("http://mobil.efa.de/mobile3/XSLT_DM_REQUEST?limit=10&locationServerActive=1&maxAssignedStops=1&mode=direct&name_dm=$query&place_dm=Hannover&type_dm=any&outputFormat=xml");

  my $xml = $response->content();

  return stations_from_xml($xml);
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

sub stations_from_xml {
  my $xml = $_[0];

  my %result = ();

  my $xp = XML::XPath->new(xml => $xml);

  foreach my $node ($xp->findnodes("//odvNameElem")) {
    my $name = get_value("\@objectName", $node);
    my $id = get_value("\@id", $node);

    $result{$id} = $name;
  }

  return %result;
}

1;

