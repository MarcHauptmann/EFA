package EFA;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(get_departures);

$VERSION = "0.0.1";

use HTML::TreeBuilder;
use WWW::Mechanize;
use HTML::TreeBuilder;
use URI::Escape;
use EFA::Departure;
use EFA::Utils;
use utf8;
use strict;
use warnings;

# Extrahiert die Werte für die Zeilen
sub extract_lines {
  my $tree = HTML::TreeBuilder->new();
  $tree->parse_content($_[0]);

  # relevante Zeilen in der Tabelle
  my @lines = $tree->look_down("_tag", "tr",
                               "class", qr/^bgcolor[0-9]*$/);

  # input-Felder für die Zeilen
  my @inputs = map { $_->look_down("_tag", "input", "name", "dmLineSelection") } @lines;

  return map { $_->attr("value") } @inputs;
}

sub get_departures {
  my $mech = WWW::Mechanize->new();

  # Haltestelle eingeben
  $mech->get("http://efa.de/gvh/XSLT_STOP_INFO_REQUEST");

  $mech->field("place_si", "Hannover");
  $mech->field("name_si", $ARGV[0]);
  $mech->field("stopService", "departureBoard");
  $mech->submit();

  # alle Linien auswählen
  map { $mech->tick("dmLineSelection", $_) } extract_lines($mech->content);

  $mech->submit();

  # Ergebnis aufhübschen
  my $tree = HTML::TreeBuilder->new();
  $tree->parse_content($mech->content);

  my @lines = $tree->look_down("_tag", "tr",
                               "class", qr/^norm/);

  my @values = ();

  foreach my $line (@lines) {
    my @data = map { $_->as_text()} $line->look_down("_tag", "td");

    my $time = parse_time($data[0]);

    my $dep = EFA::Departure->new();
    $dep->set_time($time);
    $dep->set_line($data[2]);
    $dep->set_destination($data[3]);

    push @values, $dep;
  }

  return @values;
}

1;

