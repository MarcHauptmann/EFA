#!/usr/bin/perl

use Test::More;
use EFA::Departure;
use DateTime;
use DateTime::Duration;
use strict;
use warnings;

subtest "Linie 100 ist 'Bus'" => sub {
  my $departure = EFA::Departure->new();
  $departure->set_line(100);

  is($departure->get_type(), "Bus", "Linie 100 ist Bus");
};

subtest "Linie 1 ist 'Stadtbahn'" => sub {
  my $departure = EFA::Departure->new();
  $departure->set_line(1);

  is($departure->get_type(), "Stadtbahn", "Linie 1 ist Stadtbahn");
};

subtest "Abfahrzeit kann berechnet werden" => sub {
  my $wait_time = DateTime::Duration->new(hours => 2, minutes => 2.5);

  my $time = DateTime->now(time_zone => "local");
  $time->add_duration($wait_time);

  my $departure = EFA::Departure->new();
  $departure->set_time($time);

  is($departure->get_wait_str(), "2:02", "Abfahrt in 2 Minuten");
};

subtest "Stunden werden bei Abfahrzeit weggelassen wenn unnötig" => sub {
  my $wait_time = DateTime::Duration->new(hours => 0, minutes => 20.5);

  my $time = DateTime->now(time_zone => "local");
  $time->add_duration($wait_time);

  my $departure = EFA::Departure->new();
  $departure->set_time($time);

  is($departure->get_wait_str(), "20", "Abfahrt in 2 Minuten");
};

subtest "Wenn Abfahrten einen Tag auseinander liegen werden Stunden angezeigt" => sub {
  my $wait_time = DateTime::Duration->new(hours => 24, minutes => 20);

  my $time = DateTime->now(time_zone => "local");
  $time->add_duration($wait_time);

  my $departure = EFA::Departure->new();
  $departure->set_time($time);

  is($departure->get_wait_str(), "24:20", "Abfahrt in 2 Minuten");
};

  subtest "Endstation kann Konstruktor übergeben werden" => sub {
    my $departure = EFA::Departure->new(destination => "Test");

    is($departure->get_destination(), "Test", "Endstation stimmt");
  };

done_testing();

