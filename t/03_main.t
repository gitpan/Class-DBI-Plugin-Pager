#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 18;
use Test::Exception;

use Test::Pod::Coverage;
pod_coverage_ok( 'Class::DBI::Plugin::Pager', 'POD coverage' );

# this represents a single page of results
my @dataset = qw( fee fi fo foo fum );

{
    package TestApp;
    use base 'Class::DBI';

    use Class::DBI::Plugin::Pager;

    sub count_search_where { 27 }

    # the '@_' appends the class name, SQL and bind values passed in from
    # search_where_limitable
    sub retrieve_from_sql { @dataset, @_ }

    sub __driver { 'MySQL' } # LimitOffset syntax
}


my $where = { this => 'that' };
my $order_by = [ 'fig' ];

my ( $pager, @results );

#lives_ok { ( $pager, @results ) = TestApp->search_where_paged( { this => 'that' },
#                                                               { order_by => 'fig' },
#                                                               scalar( @dataset ),
#                                                               3,
#                                                               ) } 'survived search_where_paged';

lives_ok { $pager = TestApp->pager } 'get pager - no args';

isa_ok( $pager, 'Data::Page', 'the pager' );

lives_ok { $pager->page( 3 ) } 'set page';
lives_ok { $pager->per_page( scalar( @dataset ) ) } 'set per_page';
lives_ok { $pager->where( $where ) } 'set where';
lives_ok { $pager->order_by( $order_by ) } 'set order_by';
lives_ok { @results = $pager->search_where } 'search_where';

is_deeply( \@results, [ @dataset, 'TestApp', '( this = ? ) ORDER BY fig LIMIT 5 OFFSET 10', 'that' ], 'LimitOffset results' );

is_deeply( [ $pager->current_page,
             $pager->total_entries,
             $pager->last_page,
             ],
           [ 3, 27, int( 27 / scalar( @dataset ) ) + 1 ],
           'pager numbers' );

# -----------------------
my %conf = ( page => 3,
             per_page => scalar( @dataset ),
             where => $where,
             order_by => $order_by,
             syntax => 'RowsTo',
             );

lives_ok { $pager = TestApp->pager( %conf ) } 'pager - named args';
lives_ok { @results = $pager->search_where } 'search_where';

is_deeply( \@results, [ @dataset, 'TestApp', '( this = ? ) ORDER BY fig ROWS 10 TO 15', 'that' ], 'RowsTo results' );

$pager = TestApp->pager;

$conf{syntax} = 'LimitXY';

lives_ok { @results = $pager->search_where( %conf ) } 'search_where - named args';

is_deeply( \@results, [ @dataset, 'TestApp', '( this = ? ) ORDER BY fig LIMIT 10, 5', 'that' ], 'LimitXY results' );

my @args = ( $where, $order_by, scalar( @dataset ), 3, 'RowsTo' );

lives_ok { $pager = TestApp->pager( @args ) } 'pager - positional args';
lives_ok { @results = $pager->search_where } 'search_where';
is_deeply( \@results, [ @dataset, 'TestApp', '( this = ? ) ORDER BY fig ROWS 10 TO 15', 'that' ], 'RowsTo results' );


#use YAML;
#warn Dump( $pager );
