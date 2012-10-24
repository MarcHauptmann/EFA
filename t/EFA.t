#!/usr/bin/perl

use Test::More;
use strict;
use warnings;

BEGIN { use_ok( 'EFA' ); }

sub read_test_xml {
  my $file = $_[0];

  open XML, "<$file" or die "Input konnte nicht gelesen werden";

  my $text = "";

  while (<XML>) {
    $text .= $_;
  }

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
  is($departures[0]->get_type(), "Bahn", "erste Abhfahrt ist Stadtbahn");

  # letzte Abfahrt
  is($departures[4]->get_line(), 1, "letzte Linie ist 1");
  is($departures[4]->get_destination(), "Laatzen", "letzte Linie fährt nach Laatzen");
  is($departures[4]->get_time(), $time2, "letzte Abfahrt ist um 20:55 am 20.10.2012");
  is($departures[4]->get_type(), "Bahn", "letzte Abhfahrt ist Stadtbahn");
};

subtest "Stationen könne gesucht werden" => sub {
  my $xml = read_test_xml("t/stations.xml");

  my %stations = stations_from_xml($xml);

  is(scalar(keys %stations), 4, "4 Stationen gefunden");
  ok($stations{25000011} =~ /^Kr.pcke$/, "Kröpcke");
  ok($stations{25000001} =~ /^Kr.pcke\/Theaterstra.e$/, "Kröpcke/Theaterstraße");
  ok($stations{839} =~ /^Kr.pckepassage$/, "Kröpckepassage");
  ok($stations{1000002256} =~ /^Kr.pcke$/, "Kröpcke");
};

done_testing();
