use Module::Build;

my $builder = Module::Build->new
(
 dist_name => "EFA",
 dist_version_from => "lib/EFA.pm",
 dist_author => "Marc Hauptmann <marc.hauptmann@stud.uni-hannover.de>",
 dist_abstract => "Zugriff auf efa.de",
 requires => {
	      "HTML::TreeBuilder" => 0,
	      "WWW::Mechanize" => 0,
	      "HTML::TreeBuilder" => 0,
	      "URI::Escape" => 0
	     },
 build_requires => {
		    "Test::More" => 0
		    }
);

$builder->create_build_script();
