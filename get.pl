#!/usr/bin/perl

use utf8;
use strict;
use EFA;
use POSIX;

binmode(STDOUT, ":utf8");

my @lines = get_departures($ARGV[0]);

for my $line (@lines) {
  printf $line->get_wait_str()." ".$line->get_line()." ".$line->get_destination()."\n";
}

