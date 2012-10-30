#!/usr/bin/perl

use Test::More;
use EFA::Utils;
use DateTime;
use strict;
use warnings;

subtest "normale Zeit kann geparst werden" => sub {
  my $str = "03:14";
  my $result = parse_time($str);

  is($result->hour, 3, "Stunde ist 3");
  is($result->minute, 14, "Minute ist 4");
};

subtest "Zeitangabe bezieht sich auf heute" => sub {
  my $str = "03:14";
  my $today = DateTime->now(time_zone => "local");
  my $result = parse_time($str);

  is($result->day, $today->day, "Tag stimmt");
  is($result->month, $today->month, "Monat stimmt");
  is($result->year, $today->year, "Jahr stimmt");
};

subtest "Zeit mit Datum kann geparst werden" => sub {
  my $str = "20.10.2012\t00:10";

  my $result = parse_time($str);

  is($result->mday, 20, "Tag ist 20");
  is($result->mon, 10, "Monat ist 10");
  is($result->hour, 0, "Stunde ist 0");
  is($result->minute, 10, "Minute ist 10");
  is($result->year, 2012, "Jahr ist 2012");
};

subtest "Minimum mehrerer Werte kann berechnet werden" => sub {
  is(min(), undef, "Minimum von leerer Liste ist undef");
  is(min(1), 1, "min(1) = 1");
  is(min(3, -5, 2), -5, "min(3, -5, 2) = -5");

  my @list = (3, 2, 1);

  is(min(@list), 1, "Minimum von Listen kann berechnet werden");
};

subtest "Datum kann gesetz werden" => sub {
  my $date = DateTime->now();

  set_date(\$date, "10.12.2001");

  is($date->day, 10, "Tag ist 10");
  is($date->month, 12, "Monat ist 12");
  is($date->year, 2001, "Jahr ist 2001");
};

subtest "Zeit kann gesetzt werden" => sub {
  my $date = DateTime->now();

  set_time(\$date, "03:14");

  is($date->hour, 3, "Stunde ist 03");
  is($date->minute, 14, "Minute ist 14");
};

done_testing();
