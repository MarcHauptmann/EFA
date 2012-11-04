package EFA::Config;

use strict;
use warnings;

use Moose;
use Config::File qw(read_config_file);

has "base_dir" => (isa => "Str",
                   is => "ro",
                   reader => "get_base_dir",
                   default => $ENV{HOME}
                  );

has "default_city" => (isa => "Str",
		       is => "ro",
		       reader => "get_default_city",
		       writer => "_set_default_city");

sub init {
  my ($this) = @_;

  my $conf_dir = $this->get_base_dir()."/.efa";

  # Verzeichnis anlegen
  mkdir($conf_dir);

  if (-e "$conf_dir/config") {
    my $conf_hash = read_config_file($this->get_base_dir()."/.efa/config");

    if(defined $conf_hash->{city}) {
      $this->_set_default_city($conf_hash->{city});
    }
  }
}

1;
