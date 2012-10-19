package EFA::Departure;

use Moose;
use strict;
use DateTime;
use strict;
use warnings;

has "time" => (isa => "Ref",
               is => "rw",
               reader => "get_time",
               writer => "set_time");

has "destination" => (isa => "Str",
                      is => "rw",
                      reader => "get_destination",
                      writer => "set_destination");

has "line" => (isa => "Int",
               is => "rw",
               reader => "get_line",
               writer => "set_line");

has "id" => (isa => "Int",
	     is => "rw",
	     reader => "get_id",
	     writer => "set_id");

sub get_type {
  my $self = shift;

  if ($self->get_line() >= 100) {
    return "Bus";
  } else {
    return "Bahn";
  }
}

sub get_wait_str {
  my $self = shift;
  my $now = DateTime->now(time_zone => "local");

  my $diff = $self->get_time()-$now;

  my $hours = $diff->hours;
  my $minutes = $diff->minutes;

  if ($hours > 0) {
    return sprintf "%d:%02d", $hours, $minutes;
  } else {
    return sprintf "%d", $minutes;
  }
}

1;
