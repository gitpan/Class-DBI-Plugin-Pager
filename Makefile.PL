use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Class::DBI::Plugin::Pager',
    'VERSION_FROM'	=> 'Pager.pm', # finds $VERSION
    'PREREQ_PM'		=> { Class::DBI => 0.90,
                         SQL::Abstract => 0,
                         Data::Page => 0,
                         Class::DBI::Plugin::AbstractCount => 0,
                         Class::Accessor => 0,
                         Class::Data::Inheritable => 0,
                         UNIVERSAL::require => 0,
                         Carp => 0,
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Pager.pm', # retrieve abstract from module
       AUTHOR     => 'David R. Baird <cpan@riverside-cms.co.uk>') : ()),
);



