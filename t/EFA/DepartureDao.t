#!/usr/bin/perl

use base qw(Test::Class);
use Test::More;
use EFA::DepartureDao;
use EFA::Departure;
use DateTime;
use strict;
use warnings;

# Setzt die Datenbank auf
sub setup_db : Test(setup) {
  init_departure_dao();
  reset_departure_schema();
}

# räumt nach einem Test wieder auf
sub tear_down_db : Test(teardown) {
  close_departure_dao();
}

# Anzahl Deparutes ist per Default 0
sub test_init : Test {
  my $result = get_departure_count();

  is($result, 0, "kein Depature gespeichert");
};

# ID wird beim Speichern gesetzt
sub test_store : Test {
  my $departure = EFA::Departure->new();
  $departure->set_line(120);
  $departure->set_destination("Test");
  $departure->set_time(DateTime->now());

  store_departure(\$departure);

  cmp_ok($departure->get_id(), ">", 0, "ID ist größer 0");
}

# store eines bestehenden Departures ändert ID nicht
sub test_update_id : Tests {
  my $departure = EFA::Departure->new();
  $departure->set_line(120);
  $departure->set_destination("Test");
  $departure->set_time(DateTime->now());

  store_departure(\$departure);

  my $id = $departure->get_id();

  store_departure(\$departure);

  is($departure->get_id(), $id, "ID wurde nicht verändert");
  is(get_departure_count(), 1, "nur eine Departure in der Datenbank");
};

# store eine bestehenden Departures macht Update
sub test_update_store : Tests {
  my $departure = EFA::Departure->new();
  $departure->set_line(120);
  $departure->set_destination("Test");
  $departure->set_time(DateTime->now());

  store_departure(\$departure);

  $departure->set_destination("Test2");

  store_departure(\$departure);

  my $stored_departure = load_departure_by_id($departure->get_id());

  is_deeply($stored_departure, $departure, "Update wurde durchgeführt");
};

# Departure kann gespeichert und geladen werden
sub test_store_load : Test(no_plan) {
  my $departure = EFA::Departure->new();
  $departure->set_line(120);
  $departure->set_destination("Test");
  $departure->set_time(DateTime->now());

  store_departure(\$departure);

  my $loaded_departure = load_departure_by_id($departure->get_id());

  isnt($loaded_departure, undef, "Departure wird geladen");
  is_deeply($loaded_departure, $departure, "Departure passt");
};

Test::Class->runtests;

