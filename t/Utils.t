#!/usr/bin/perl

use Test::More;
use EFA::Utils;
# use Time::Piece;
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
  my $str = "17.09.2010   07:30";
  my $result = parse_time($str);

  is($result->mday, 17, "Tag ist 17");
  is($result->mon, 9, "Monat ist 10");
  is($result->hour, 7, "Stunde ist 7");
  is($result->minute, 30, "Minute ist 30");
  is($result->year, 2010, "Jahr ist 2012");
};

done_testing();
