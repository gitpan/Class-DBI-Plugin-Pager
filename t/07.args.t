#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper::Simple;

plan tests => 30;

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

my %args = ( page       => 2,
             per_page   => 12,
             abstract_attr  => { cmp => 'like' },
             order_by   => 'val',
             where      => { Name => 'daffy%' },
             );
             
             
# item pager( [$where, [$abstract_attr]], [$order_by], [$per_page], [$page], [$syntax] )
# positional args
{
    my $pager;
    
    my @args = ( $args{where}, 
                 $args{abstract_attr}, 
                 $args{order_by},
                 $args{per_page},
                 $args{page},
                 );
    
    lives_ok { $pager = Foo->pager( @args ) } 'get pager - positional args';    
    
    # note - Name -> name
    is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 2, 'page' );
    is( $pager->per_page, 12, 'per_page' );
    
    #warn Dumper( $pager );
}

# item pager( [$where, [$abstract_attr]], [$order_by], [$per_page], [$page], [$syntax] )
# positional args - skip some
{
    my $pager;
    
    my @args = ( $args{where}, 
                 #$args{abstract_attr}, 
                 #$args{order_by},
                 $args{per_page},
                 $args{page},
                 );
    
    lives_ok { $pager = Foo->pager( @args ) } 'get pager - positional args';    
    
    # note - Name -> name
    is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    #is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    #is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 2, 'page' );
    is( $pager->per_page, 12, 'per_page' ); 
    
    #warn Dumper( $pager );
}

# __END__

# item pager( [$where, [$abstract_attr]], [$order_by], [$per_page], [$page], [$syntax] )
# positional args - skip others
{
    my $pager;
    
    my @args = ( #$args{where}, 
                 #$args{abstract_attr}, 
                 $args{order_by},
                 #$args{per_page},
                 #$args{page},
                 );
    
    lives_ok { $pager = Foo->pager( @args ) } 'get pager - positional args';    
    
    # note - Name -> name
    #is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    #is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 1, 'page' );          # default
    is( $pager->per_page, 10, 'per_page' ); # default
    
    #warn Dumper( $pager );
}

# item pager( [$where, [$abstract_attr]], [$order_by], [$per_page], [$page], [$syntax] )
# positional args - skip yet others
{
    my $pager;
    
    my @args = ( #$args{where}, 
                 #$args{abstract_attr}, 
                 #$args{order_by},
                 $args{per_page},
                 $args{page},
                 );
    
    lives_ok { $pager = Foo->pager( @args ) } 'get pager - positional args';    
    
    # note - Name -> name
    #is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    #is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    #is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 2, 'page' );          # default
    is( $pager->per_page, 12, 'per_page' ); # default
    
    #warn Dumper( $pager );
}

# named args
{
    my $pager;
    
    lives_ok { $pager = Foo->pager( %args ) } 'get pager - named args';    
        
    # note - Name -> name
    is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 2, 'page' );
    is( $pager->per_page, 12, 'per_page' );
}

# method calls
{
    my $pager;
    
    lives_ok { $pager = Foo->pager } 'get pager - no args';    
    
    lives_ok { $pager->$_( $args{ $_ } ) for keys %args } 'arg method calls';
    
    # note - Name -> name
    is_deeply( $pager->where,           { name => 'daffy%' }, 'where' );
    is_deeply( $pager->abstract_attr,   { cmp => 'like' }, 'abstract_attr' );
    is_deeply( $pager->order_by,        [ 'val' ], 'order_by' );
    
    is( $pager->page, 2, 'page' );
    is( $pager->per_page, 12, 'per_page' );
}    
    
 