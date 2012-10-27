#!/usr/bin/perl

use Test::More;
use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

BEGIN { use_ok( 'EFA' ); }

sub read_test_xml {
  my $file = $_[0];

  open XML, "<$file" or die "Input konnte nicht gelesen werden";

  my $text = "";

  while (<XML>) {
    $text .= $_;
  }

  close XML;

  return $text;
}

subtest "Departures können aus XML erzeugt werden" => sub {
  my $xml = read_test_xml("t/testInput.xml");

  # Departures laden
  my @departures = departures_from_xml($xml);

  is(scalar(@departures), 5, "5 Departures bekommen");
  isa_ok($departures[0], "EFA::Departure");

  # erste Abfahrt
  my $time1 = DateTime->new(year => 2012, month => 10, day => 20,
                            hour => 20, minute => 48);

  my $time2 = DateTime->new(year => 2012, month => 10, day => 20,
                            hour => 20, minute => 55);

  # erste Abfahrt
  is($departures[0]->get_line(), 2, "erste Linie ist 2");
  is($departures[0]->get_destination(), "Rethen", "erste Linie fährt nach Rethen");
  is($departures[0]->get_time(), $time1, "erste Abfahrt ist um 20:48 am 20.10.2012");
  is($departures[0]->get_type(), "Stadtbahn", "erste Abhfahrt ist Stadtbahn");
  is($departures[0]->get_station(), "Vahrenwalder Platz", "erste Station ist Vahrenwalder Platz");

  # letzte Abfahrt
  is($departures[4]->get_line(), 1, "letzte Linie ist 1");
  is($departures[4]->get_destination(), "Laatzen", "letzte Linie fährt nach Laatzen");
  is($departures[4]->get_time(), $time2, "letzte Abfahrt ist um 20:55 am 20.10.2012");
  is($departures[4]->get_type(), "Stadtbahn", "letzte Abhfahrt ist Stadtbahn");
  is($departures[4]->get_station(), "Vahrenwalder Platz", "letzte Station ist Vahrenwalder Platz");
};

subtest "Stationen können gesucht werden" => sub {
  my $xml = read_test_xml("t/stations.xml");

  my @stations = stations_from_xml($xml);

  is(scalar(@stations), 4, "4 Stationen gefunden");
  is($stations[0]->get_name(), "Hannover, Kröpcke", "Kröpcke");
  is($stations[0]->get_id(), 25000011, "ID von Kröpcke stimmt");
  is($stations[1]->get_name, "Hannover, Kröpcke\/Theaterstraße", "Kröpcke/Theaterstraße");
  is($stations[1]->get_id, 25000001, "ID von Theaterstraße passt");
  is($stations[2]->get_name, "Hannover, Kröpckepassage", "Kröpckepassage");
  is($stations[2]->get_id, 839, "ID von Kröpckepassage passt");
  is($stations[3]->get_name, "Hannover, Kröpcke", "Kröpcke");
  is($stations[3]->get_id, 1000002256, "letzte ID passt");
};

subtest "Stationsname kann gelesen werden" => sub {
  my $xml = read_test_xml("t/stations_by_id.xml");

  my @stations = stations_from_xml($xml);

  is(scalar(@stations), 1, "eine Station gefunden");
  is($stations[0]->get_name(), "Vahrenwalder Platz", "Station ist Vahrenwalder Platz");
  is($stations[0]->get_id(), 25000341, "ID stimmt");
};

done_testing();
