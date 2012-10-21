package EFA::DepartureDao;

use Exporter;
use EFA::Departure;
use DBI;
use DateTime;

@ISA = qw(Exporter);
@EXPORT  = qw(init_departure_dao
              reset_departure_schema
              get_departure_count
              store_departure
              load_departure_by_id
              close_departure_dao
              departure_is_persistent);

our $connection;

# initialisiert die Verbindung
sub init_departure_dao {
  $connection = DBI->connect("dbi:SQLite:/tmp/efa.db", "", "");
}

# Schließt die Verbindung wieder
sub close_departure_dao {
  $connection->disconnect();
}

# initialisiert das Datenbank-Schema
sub reset_departure_schema {
  $connection->do("DROP TABLE IF EXISTS departures;");
  $connection->do("CREATE TABLE departures (id INTEGER PRIMARY KEY ASC, line INTEGER, time INTEGER, destination CHAR(100));");

  $connection->do($script);
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

  $departure->set_id($$row_ref{"id"});
  $departure->set_line($$row_ref{"line"});
  $departure->set_destination($$row_ref{"destination"});
  $departure->set_time(DateTime->from_epoch(epoch => $$row_ref{"time"}));

  return $departure;
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

  if($$row_ref{"num"} > 0) {
    return 1;
  } else {
    return 0;
  }
}

1;
