package EFA::Web;

require Exporter;

@ISO = qw(Exporter);
@EXPORT = qw(request_departures request_stations);

use LWP::UserAgent;

sub request_departures {
  my ($station_id, $time, %parameters) = @_;
  my $num = $parameters{num} || 10;
  my $url = "http://mobil.efa.de/mobile3/XSLT_DM_REQUEST?maxAssignedStops=1";

  $url .= "&outputFormat=xml";
  $url .= "&mode=direct";
  $url .= "&name_dm=$station_id";
  $url .= "&limit=$num";
  $url .= "&type_dm=stopID";
  $url .= "&itdTimeHour=".$time->hour;
  $url .= "&itdTimeMinute=".$time->minute;
  $url .= "&itdDate=".$time->year.$time->month.$time->day;

  print "frage $num Abfahrten ab\n";

  my $ua = LWP::UserAgent->new();
  my $response = $ua->get($url);

  return $response->content();
}

sub request_stations {
  my ($query, $city) = @_;
  my $url = "http://mobil.efa.de/mobile3/XSLT_DM_REQUEST?maxAssignedStops=1";

  $url .= "&outputFormat=xml";
  $url .= "&mode=direct";
  $url .= "&name_dm=$query";
  $url .= "&limit=10";
  $url .= "&type_dm=any";
  $url .= "&place_dm=$city";
  $url .= "&locationServerActive=1";

  my $ua = LWP::UserAgent->new();
  my $response = $ua->get($url);

  return $response->content();
}
