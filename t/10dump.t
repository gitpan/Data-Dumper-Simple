#!/usr/bin/perl
# '$Id: 10dump.t,v 1.2 2004/07/31 19:29:15 ovid Exp $';
use warnings;
use strict;
use Test::More tests => 16;

my $CLASS;
BEGIN
{
    chdir 't' if -d 't';
    unshift @INC => '../lib';
    $CLASS = 'Data::Dumper::Simple';
    use_ok($CLASS) or die;
}

my $scalar = 'Ovid';
my @array  = qw/Data Dumper Simple Rocks!/;
my %hash   = (
    at => 'least',
    I  => 'hope',
    it => 'does',
);

is(Dumper($scalar), "\$scalar = 'Ovid';\n",
    '... and dumped variables are named');
is(Dumper(\$scalar), "\$scalar = 'Ovid';\n",
    '... and dumping a scalar as a reference is a no-op');

my $expected = Data::Dumper->Dump([\@array], ['*array']);
is(Dumper(@array), $expected, '... even if they would normally flatten');
is(Dumper(\@array), $expected, '... or if you take a reference to them');

$expected = Data::Dumper->Dump(
    [$scalar, \@array, \%hash],
    [qw/$scalar *array *hash/]
);

is(Dumper($scalar, @array, %hash), $expected,
    '... or have a list of them');

is(Dumper($scalar, \@array, \%hash), $expected,
    '... or a list of references');

is(
    Dumper(
        $scalar =>
        @array =>
        %hash
    ), 
    $expected,
    '... or fat commas "=>"');

is(
    Dumper( $scalar => @array =>
        %hash
    ), 
    $expected,
    '... regardless of whitespace');

is(
    Dumper(
        $scalar, 
        @array, 
        %hash
    ), 
    $expected,
    '... and even do the right thing if there are newlines in the arg list');

$Data::Dumper::Indent = 1;
$expected = Data::Dumper->Dump(
    [$scalar, \@array, \%hash],
    [qw/$scalar *array *hash/]
);

is(Dumper($scalar, @array, %hash), $expected,
    '... and $Data::Dumper::Indent is respected');

my $foo   = { hash => 'ref' };
my @foo   = qw/foo bar baz/;
$expected = Data::Dumper->Dump(
    [$foo, \@foo],
    [qw/$foo *foo/],
);

is(Dumper($foo, \@foo), $expected,
     '... and a reference to a simarly named variable won\'t confuse things');

is(Dumper($array[2]), "\$array[2] = 'Simple';\n",
    "Indexed items in arrays are dumped intuitively.");

my $aref = \@array;

is(Dumper($aref->[2]), "\$aref->[2] = 'Simple';\n",
    "... even if they're references");

is(Dumper($hash{at}), "\$hash{at} = 'least';\n",
    "Indexed items in hashes are dumped intuitively");

my $href = \%hash;
is(Dumper($href->{at}), "\$href->{at} = 'least';\n",
    "... even if they're references");
