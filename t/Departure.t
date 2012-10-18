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

subtest "Linie 1 ist 'Bahn'" => sub {
  my $departure = EFA::Departure->new();
  $departure->set_line(1);

  is($departure->get_type(), "Bahn", "Linie 1 ist Bahn");
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

done_testing();

