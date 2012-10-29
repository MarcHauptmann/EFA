#!/usr/bin/perl

use base qw(Test::Class);
use Test::More;
use EFA::DB;
use EFA::Departure;
use EFA::Station;
use DateTime;
use POSIX qw(floor);
use strict;
use warnings;

# Setzt die Datenbank auf
sub setup_db : Test(setup) {
  init_db( url => "dbi:SQLite:dbname=:memory:");
  reset_db_schema();
}

# räumt nach einem Test wieder auf
sub tear_down_db : Test(teardown) {
  close_db();
}

# Anzahl Deparutes ist per Default 0
sub test_init : Test {
  my $result = get_departure_count();

  is($result, 0, "kein Depature gespeichert");
}
;

# Standard-Departure erstellen
sub make_departure {
  my %parameters = @_;

  my $minute_offset = $parameters{minute_offset} || 0;

  my $time = DateTime->now(time_zone => "Europe/Berlin");
  $time->add(minutes => $minute_offset);

  return EFA::Departure->new(line => 120,
                             destination => "Test",
                             time => $time);
}

# ID wird beim Speichern gesetzt
sub test_store : Tests {
  my $departure = make_departure();

  # speichern
  store_departure(\$departure);

  cmp_ok($departure->get_id(), ">", 0, "ID ist größer 0");
  is(get_departure_count(), 1, "ein Departure gespeichert");
}

# store eines bestehenden Departures ändert ID nicht
sub test_update_id : Tests {
  my $departure = make_departure();

  # speichern
  store_departure(\$departure);

  my $id = $departure->get_id();

  # speichern -> Update
  store_departure(\$departure);

  is($departure->get_id(), $id, "ID wurde nicht verändert");
  is(get_departure_count(), 1, "nur eine Departure in der Datenbank");
}
;

# store eine bestehenden Departures macht Update
sub test_update_store : Tests {
  my $departure = make_departure();

  # speichern
  store_departure(\$departure);

  $departure->set_destination("Test2");

  # speichern -> Update
  store_departure(\$departure);

  my $stored_departure = load_departure_by_id($departure->get_id());

  is_deeply($stored_departure, $departure, "Update wurde durchgeführt");
}
;

# Departure kann gespeichert und geladen werden
sub test_store_load : Tests {
  my $departure = make_departure();

  # speichern
  store_departure(\$departure);

  # wieder laden
  my $loaded_departure = load_departure_by_id($departure->get_id());

  isnt($loaded_departure, undef, "Departure wird geladen");
  is_deeply($loaded_departure, $departure, "geladenes Departure stimmt mit gespeicherten überein");
}
;

# Existenz einer vorhandenen Departure kann geprüft werden
sub test_departure_is_persistent : Tests {
  my $departure = make_departure();
  my $departure_copy = make_departure();

  # erstes Mal ist nicht persistent
  my $result_not_persistent = departure_is_persistent(\$departure_copy);

  # speichern
  store_departure(\$departure);

  is($result_not_persistent, 0, "Departure ist nicht in Datenbank vorhanden");

  # zweites Mal ist persistent
  my $result_persistent = departure_is_persistent(\$departure_copy);

  is($result_persistent, 1, "Departure ist in Datenbank vorhanden");
}
;

# Abfahrten können anhand der Zeit gesucht werden
sub test_search_departures_by_time : Tests {
  my $departure1 = make_departure(minute_offset => -10);
  my $departure2 = make_departure(minute_offset => 5);
  my $departure3 = make_departure(minute_offset => 65);

  store_departure(\$departure1);
  store_departure(\$departure2);
  store_departure(\$departure3);

  my @departures = load_departures(after => DateTime->now());

  is(scalar(@departures), 2, "zwei Abfahrten");
  is_deeply($departures[0], $departure2, "erste Abfahrt stimmt");
  is_deeply($departures[1], $departure3, "zweite Abfahrt stimmt");
}

# Testet das Löschen aller Departures
sub test_delete_departures : Tests {
  my $departure1 = make_departure(minute_offset => -10);
  my $departure2 = make_departure(minute_offset => 5);

  store_departure(\$departure1);
  store_departure(\$departure2);

  delete_departures();

  is(get_departure_count(), 0, "keine Departures mehr in der Datenbank");
}

# Speichern einer Station funktioniert
sub test_store_station : Tests {
  my $station = EFA::Station->new(id => 1, name => "Test");

  store_station(\$station);

  my $persistent_station = load_station_by_id(1);

  is_deeply($persistent_station, $station);
}

# Alle gespeicherten Station können geladen werden
sub test_load_all_stations : Tests {
  my $station1 = EFA::Station->new(id => 10, name => "Test1");
  my $station2 = EFA::Station->new(id => 21, name => "Test2");
  my $station3 = EFA::Station->new(id => 1123, name => "Test3");

  store_station(\$station1);
  store_station(\$station2);
  store_station(\$station3);

  my @stations = load_all_stations();

  is(scalar(@stations), 3, "3 Stationen");
  is_deeply($stations[0], $station1, "Station 1 passt");
  is_deeply($stations[1], $station2, "Station 2 passt");
  is_deeply($stations[2], $station3, "Station 3 passt");
}

# eine Station kann gelöscht werden
sub test_delete_station : Tests {
  my $station = EFA::Station->new(id => 10, name => "Test1");

  store_station(\$station);

  delete_station($station->get_id());

  is(load_station_by_id($station->get_id), undef, "Station kann nicht mehr geladen werden");
}

Test::Class->runtests;

