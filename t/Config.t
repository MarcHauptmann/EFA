#!/usr/bin/perl

use base qw(Test::Class);
use Test::More;
use File::Temp qw(tempdir);

sub create_config {
  my ($config) = @_;

  my $dir = tempdir( CLEANUP => 0);

  mkdir("$dir/.efa");

  open(CONFIG, ">", "$dir/.efa/config");

  print CONFIG $config;

  close(CONFIG);

  return $dir;
}

# ------------------ Tests -----------------------------------------------------

use_ok("EFA::Config");

sub test_creation : Tests {
  my $config = EFA::Config->new(base_dir => "/tmp");

  is($config->get_base_dir(), "/tmp", "Base-Dir kann gesetzt werden");
}

sub base_dir_is_home_by_default : Tests {
  my $config = EFA::Config->new();

  is($config->get_base_dir(), $ENV{HOME}, "Base-Dir ist Home-Dir");
}

sub init_creates_base_dir : Test {
  my $dir = tempdir( CLEANUP => 1);

  my $config = EFA::Config->new(base_dir => $dir);
  $config->init();

  ok(-d "$dir/.efa", "Config-Dir existiert");
}

sub default_city_can_be_set : Tests {
  my $data = <<EOF;
city = Hannover
EOF

  my $dir = create_config($data);

  my $config = EFA::Config->new(base_dir => $dir);
  $config->init();

  is($config->get_default_city(), "Hannover", "Standard-Stadt kann gelesen werden");
}

Test::Class->runtests;
