#!/usr/bin/perl
#
# CGI-Skript für die Ausgabe der letzten Abfahrten im JSON-Format

use CGI::Fast;
use EFA::DB;
use DateTime;
use JSON::PP;
use utf8;

#binmode(STDOUT, ":utf8");

init_db( url => "dbi:SQLite:dbname=/home/marc/.efa" );

while (my $query = CGI::Fast->new()) {
  my @departures = load_departures(after => DateTime->now(time_zone => "local"),
                                   num => 10);

  my @list = ();

  foreach my $departure (@departures) {
    push @list, {line => $departure->get_line,
                 type => $departure->get_type,
                 destination => $departure->get_destination,
                 wait => $departure->get_wait_str,
                 station => $departure->get_station->get_name};
  }

  print $query->header(-type => "application/json",
                       -charset => "utf8");

  print encode_json \@list;
}

close_db();
