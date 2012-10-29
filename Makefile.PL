use ExtUtils::MakeMaker;

WriteMakefile(
              AUTHOR => "Marc Hauptmann",
              NAME => "EFA",
              VERSION_FROM => "lib/EFA.pm",
              PREREQ_PM => {
                            Text::Table => 0,
                            XML::XPath => 0,
                            LWP::UserAgent => 0,
                            Moose => 0,
                            DateTime => 0,
                            DBI => 0,
                            Getopt::Long => 0,
                            Pod::Usage => 0,
                            Text::Table => 0
                           },
              EXE_FILES => [ qw(bin/efa-departures
                                bin/efa-station
                                bin/efa-setup) ]
             );
