#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper::Simple;

plan tests => 16;

# Lifted from CDBI::mysql tests

#-------------------------------------------------------------------------
# Let the testing begin
#-------------------------------------------------------------------------

package Foo;

use base 'Class::DBI::mysql';

use Class::DBI::Plugin::AbstractCount;  
use Class::DBI::Plugin::Pager;

# Find a test database to use.

my $db   = $ENV{DBD_MYSQL_DBNAME} || 'test';
my $user = $ENV{DBD_MYSQL_USER}   || '';
my $pass = $ENV{DBD_MYSQL_PASSWD} || '';
my $tbl  = $ENV{DBD_MYSQL_TABLE}  || 'dbcdbipptest';

__PACKAGE__->set_db(Main => "dbi:mysql:$db", $user => $pass);
__PACKAGE__->table($tbl);
__PACKAGE__->drop_table;
__PACKAGE__->create_table(q{
    id     MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name   VARCHAR(50)        NOT NULL DEFAULT '',
    val    SMALLINT UNSIGNED  NOT NULL DEFAULT 'A',
    mydate TIMESTAMP          NOT NULL
});
__PACKAGE__->set_up_table;

sub accessor_name {
    my ( $class, $column ) = @_;
    
    return "cartoon$column";
}

END { __PACKAGE__->drop_table }

#-------------------------------------------------------------------------

package main;

my $name  = 'daffy00';
my $name2 = 'porky000';
my $val = 999;

for ( 1 .. 30 )
{
    Foo->create( { Name => $name++,
                   val  => $val--,
                   } );
    # daffy00 daffy01 daffy02 ..                   
}    

for ( 1 .. 200 )
{
    Foo->create( { Name => $name2++,
                   val  => $val--,
                   } );
}    
#-------------------------------------------------------------------------

{   
    my ( $it, @results );
    
    foreach my $cname ( qw( Name cartoonName ) )
    {
        foreach my $cval ( qw( val cartoonval ) )
        {
    
            my @search = ( { $cname => 'daffy%' },
                           { cmp => 'like',
                               order_by => $cval 
                               },
                           10,      # per page
                           3,       # page number
                           );
            
            lives_ok { @results = Foo->pager->search_where( @search ) } 'survived search_where';
            
            ok( @results == 10, 'got 10 ducks' );
            
            lives_ok { $it = Foo->pager->search_where( @search ) } 'survived search_where';
            
            is( $it->count, 10, 'got 10 ducks from iterator' );
        }
    }
}

