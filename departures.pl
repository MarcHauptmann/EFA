#!/usr/bin/perl

use utf8;
use strict;
use EFA;
use POSIX;
use Text::Table;

binmode(STDOUT, ":utf8");

my @departures = get_departures($ARGV[0]);

if (scalar(@departures) > 0) {
  my $table = Text::Table->new("Minuten", "Linie", "Ziel");

  for my $line (@departures) {
    $table->add($line->get_wait_str(),
                $line->get_line(),
                $line->get_destination());
  }

  print $table->title;
  print $table->rule("-");
  print $table->body;
} else {
  print "Keine Abfahrten gefunden\n";
}

