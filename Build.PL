use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Class::DBI::Plugin::Pager',
    license             => 'perl',
    dist_author         => 'David Baird <cpan@riverside-cms.co.uk>',
    dist_version_from   => 'lib/Class/DBI/Plugin/Pager.pm',
    requires => { Test::More => 0,
                  Test::Exception => 0,
                  Class::DBI => 0.90,
                  SQL::Abstract => 0,
                  Data::Page => 0,
                  Class::DBI::Plugin::AbstractCount => 0,
                  Class::Accessor => 0,
                  Class::Data::Inheritable => 0,
                  UNIVERSAL::require => 0,
                  Carp => 0,
                  },
    add_to_cleanup      => [ 'Class-DBI-Plugin-Pager-*' ],
);

$builder->create_build_script();
