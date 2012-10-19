package EFA::Utils;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(parse_time);

use DateTime;
use strict;
use warnings;

sub parse_time {
  my $time_str = $_[0];
  my $now = DateTime->now(time_zone => "local");

  if ($time_str =~ /^(\d\d?)\.(\d\d?)\.(\d*).*(\d\d?):(\d\d?)/) {
    my $day = $1;
    my $mon = $2;
    my $year = $3;
    my $hour = $4;
    my $min = $5;

    $now->set(day => $day, month => $mon, year => $year, hour => $hour, minute => $min);
  } elsif($time_str =~ /^(\d\d):(\d\d)$/) {
    my $hour = $1;
    my $min = $2;

    $now->set(hour => $hour, minute => $min);
  } else {
    die "unbekanntes Format";
  }
  
  return $now;
}
