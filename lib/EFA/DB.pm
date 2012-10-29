package EFA::DB;

use Exporter;
use EFA::Departure;
use EFA::Station;
use DBI;
use DateTime;

@ISA = qw(Exporter);
@EXPORT  = qw(init_db
              reset_db_schema
              get_departure_count
              close_db
              store_departure
              load_departure_by_id
              departure_is_persistent
              store_station
              load_station_by_id
              load_all_stations
              load_departures
              delete_departures
              delete_station);

our $connection;

# initialisiert die Verbindung
sub init_db {
  my %parameters = @_;

  my $url = $parameters{url} || "dbi:SQLite:dbname=".$ENV{HOME}."/.efa";

  $connection = DBI->connect($url, "", "",
                             {
                              sqlite_unicode => 1
                             });
}

# Schließt die Verbindung wieder
sub close_db {
  $connection->disconnect();
}

# initialisiert das Datenbank-Schema
sub reset_db_schema {
  my $script = <<EOF;
-- alte Tabellen löschen
DROP TABLE IF EXISTS departures;
DROP TABLE IF EXISTS stations;

-- neue Tabellen erstellen
CREATE TABLE departures (id INTEGER PRIMARY KEY ASC, line INTEGER, time INTEGER, destination CHAR(100));
CREATE TABLE stations (id INTEGER PRIMARY KEY, name CHAR(100));
EOF

  foreach my $line (split /\n/, $script) {
    $connection->do($line);
  }
}

# Zäht die Departures in der Datenbank
sub get_departure_count {
  my @val = $connection->selectrow_array("SELECT COUNT(*) FROM departures");

  return $val[0];
}

# Speichert eine Departure
sub store_departure {
  my $departure = ${$_[0]};
  my $line = $departure->get_line();
  my $dest = $departure->get_destination();
  my $epoch = $departure->get_time()->epoch();

  if (defined $departure->get_id()) {
    my $id = $departure->get_id();

    my $stmt = "UPDATE departures SET line=%d, destination='%s', time=%d WHERE id=%d;";

    $connection->do(sprintf $stmt, $line, $dest, $epoch, $id);
  } else {
    my $stmt =  "INSERT INTO departures (line, destination, time) VALUES ('%d', '%s', '%d');";

    $connection->do(sprintf $stmt, $line, $dest, $epoch);

    my $id = $connection->selectrow_array("SELECT last_insert_rowid();");

    $departure->set_id($id);
  }
}

# Lädt eine Departure anhand ihrer ID
sub load_departure_by_id {
  my $id = $_[0];
  my $departure = EFA::Departure->new();
  my $query = sprintf "SELECT * FROM departures WHERE id=%d;", $id;
  my $row_ref = $connection->selectrow_hashref($query);

  if (not defined $row_ref) {
    die "Fehler";
  }

  my $time = DateTime->from_epoch(epoch => $$row_ref{"time"}, time_zone => "local");

  $departure->set_id($$row_ref{"id"});
  $departure->set_line($$row_ref{"line"});
  $departure->set_destination($$row_ref{"destination"});
  $departure->set_time($time);

  return $departure;
}

# Lädt Departures
sub load_departures {
  my %parameters = @_;

  my $after = $parameters{after};

  my @departures = ();

  my $query = sprintf "SELECT * FROM departures WHERE time >= %d", $after->epoch;
  my $row_ref = $connection->selectall_arrayref($query, { Slice => {} });

  foreach my $row (@$row_ref) {
    my $time = DateTime->from_epoch(epoch => $row->{time}, time_zone => "local");

    push @departures, EFA::Departure->new(id => $row->{id},
                                          destination => $row->{destination},
                                          time => $time,
                                          line => $row->{line});
  }

  return @departures;
}

# löscht alle Departures
sub delete_departures {
  $connection->do("DELETE FROM departures;");
}

# Existenz in der Datenbank kann geprüft werden
sub departure_is_persistent {
  $departure = ${$_[0]};

  my $line = $departure->get_line;
  my $dest = $departure->get_destination;
  my $time = $departure->get_time->epoch;

  my $query = <<EOF;
SELECT COUNT(*) AS num FROM departures WHERE
    line=$line AND destination='$dest' AND time=$time;
EOF

  my $row_ref = $connection->selectrow_hashref($query);

  if ($$row_ref{"num"} > 0) {
    return 1;
  } else {
    return 0;
  }
}

######################################################################

# speichert eine Station
sub store_station {
  my $station = ${$_[0]};
  my $id = $station->get_id();
  my $name = $station->get_name();

  $connection->do("INSERT INTO stations (id, name) VALUES ($id, '$name');");
}

# lädt eine Station anhand der ID
sub load_station_by_id {
  my $id = $_[0];

  my $row_ref = $connection->selectrow_hashref("SELECT * FROM stations WHERE id=$id");

  if (defined $row_ref) {
    return EFA::Station->new(id => $id, name => $row_ref->{"name"});
  } else {
    return undef;
  }
}

sub load_all_stations {
  my @stations = ();

  my $row_ref = $connection->selectall_arrayref("SELECT * FROM stations", {Slice => {}});

  foreach my $row (@$row_ref) {
    push @stations, EFA::Station->new(id => $row->{"id"}, name => $row->{"name"});
  }

  return @stations;
}

sub delete_station {
  my $id = $_[0];

  $connection->do("DELETE FROM stations WHERE id=$id;");
}

1;
