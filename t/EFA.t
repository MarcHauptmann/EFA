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

  # find_station umdefinieren
  undef &EFA::find_station;
  local *EFA::find_station = sub { return EFA::Station->new( name => "") };

  # Departures laden
  my @departures = departures_from_xml($xml);

  is(scalar(@departures), 5, "5 Departures bekommen");
  isa_ok($departures[0], "EFA::Departure");

  my $station = EFA::Station->new(id => 25000341, name => "Vahrenwalder Platz");

  my $departure1 = EFA::Departure->new(line => 2, destination => "",
                                       type => "Stadtbahn", station => $station);
  $departure1->set_time(DateTime->new(year => 2012, month => 10, day => 20,
                                      hour => 20, minute => 48));

  my $departure2 = EFA::Departure->new(line => 1, destination => "",
                                       type => "Stadtbahn", station => $station);
  $departure2->set_time(DateTime->new(year => 2012, month => 10, day => 20,
                                      hour => 20, minute => 55));

  # erste Abfahrt
  is_deeply($departures[0], $departure1, "erste Abfahrt stimmt");

  # letzte Abfahrt
  is_deeply($departures[4], $departure2, "letzte Abfahrt stimmt");
};

subtest "Destination ist leer wenn Station nicht gefunden werden konnte" => sub {
  my $xml = read_test_xml("t/testInput.xml");

  # find_station umdefinieren
  undef &EFA::find_station;
  local *EFA::find_station = sub { return () };

  # Departures laden
  my @departures = departures_from_xml($xml);

  # Abfahrt
  is_deeply($departures[0]->get_destination, "", "Destination ist leer");
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
