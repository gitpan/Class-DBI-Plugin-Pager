#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper::Simple;

plan tests => 19;

use_ok "Class::DBI::mysql";

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

# kick off
{   
    my ( $it, @results );
    
    my @search = ( { Name => 'daffy%' },
                   { cmp => 'like',
                     order_by => 'val' 
                     },
                   10,      # per page
                   3,       # page number
                   );
    
    lives_ok { @results = Foo->pager->search_where( @search ) } 'survived search_where';
    
    ok( @results == 10, 'got 10 ducks' );
    
    lives_ok { $it = Foo->pager->search_where( @search ) } 'survived search_where';
    
    is( $it->count, 10, 'got 10 ducks from iterator' );
    
}

# pager settings
{
    my ( $pager, @results );
    
    lives_ok { $pager = Foo->pager } 'get pager - no args';
    
    isa_ok( $pager, 'Data::Page', 'the pager' );
    
    lives_ok { $pager->page( 2 ) } 'set page';
    lives_ok { $pager->per_page( 10 ) } 'set per_page';
    lives_ok { $pager->where( { Name => 'daffy%' } ) } 'set where';
    lives_ok { $pager->order_by( 'val' ) } 'set order_by';
    
    $pager->add_attr( cmp => 'like' );
    is( $pager->abstract_attr->{cmp}, 'like', 'added an attr' );
    
    lives_ok { @results = $pager->search_where } 'search_where';
    
    ok( @results == 10, 'got 10 ducks' );
    
    is_deeply( [ $pager->current_page,
                 $pager->total_entries,
                 $pager->last_page,
                 ],
               [ 2, 30, 3 ],
               'pager numbers',
               );    

    #warn Dumper( $pager );

}

# named arguments
{
    my ( $pager, @results );
    
    my %conf = ( page       => 5,
                 per_page   => 15,
                 where      => { Name => 'porky%' },
                 abstract_attr  => { cmp => 'like' },
                 order_by   => 'val',
                 syntax     => 'LimitXY',
                 );
    
    lives_ok { $pager = Foo->pager( %conf ) } 'pager - named args';
    lives_ok { @results = $pager->search_where } 'search_where';
    
    is( scalar @results, 15, '15 porkies' );
    
    is_deeply( [ $pager->current_page,
                 $pager->total_entries,
                 $pager->last_page,
                 ],
               [ 5, 200, 14 ],
               'pager numbers',
               );    

}    
    
    
