package EFA::Station;

use Moose;
use strict;
use warnings;

has "id" => (isa => "Int",
             is => "rw",
             reader => "get_id",
             writer => "set_id");

has "name" => (isa => "Str",
               is => "rw",
               reader => "get_name",
               writer => "set_name");

1;
