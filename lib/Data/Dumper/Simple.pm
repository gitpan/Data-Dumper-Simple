package Data::Dumper::Simple;

$REVISION = '$Id: Simple.pm,v 1.4 2004/07/31 19:35:10 ovid Exp $';
$VERSION  = '.02';
use Filter::Simple;
use Data::Dumper ();

FILTER_ONLY 
    code => sub {
        s{
            Dumper\s*\(([^)]+)\)
        }{
            my ($references, $names) = _munge_argument_list($1);
            "Data::Dumper->Dump(
                [$references],
                [qw/$names/]
            )"
        }gex
    };

sub _munge_argument_list {
    my $arguments    = shift;
    my $sigils       = '@%&';
    my @raw_vars     = split /\s*(?:,|=>)\s*/ => $1;
    my $escaped_vars = 
        join ', ' => 
        map { s/\\\$/\$/g; $_ }
        map { s/(?<!\\)(?=[$sigils])/\\/g; $_ } 
            @raw_vars;
    
    my $varnames  = 
        join ' ' => 
        map { s/\\//g; s/[$sigils]/*/; $_ } 
            @raw_vars;

    return ($escaped_vars, $varnames);
}

1;

__END__

=head1 NAME

Data::Dumper::Simple - Easily dump variables with names

=head1 SYNOPSIS

  use Data::Dumper::Simple;
  warn Dumper($scalar, @array, %hash);

=head1 ABSTRACT

  This module allow the user to dump variables in a Data::Dumper format.
  Unlike the default behavior of Data::Dumper, the variables are named
  (instead of $VAR1, $VAR2, etc.)  Data::Dumper provides an extended 
  interface that allows the programmer to name the variables, but this
  interface requires a lot of typing and is prone to tyops (sic).  This 
  module fixes that.

=head1 DESCRIPTION

C<Data::Dumper::Simple> is actually a source filter that replaces all instances
of C<Dumper($some, @args)> in your code with a call to
C<Data::Dumper-E<gt>Dump()>.  You can use the one function provided to make
dumping variables for debugging a trivial task.

Note that this is primarily a debugging tool.  C<Data::Dumper> offers a bit
more than that, so don't expect this module to be more than it is.

=head2 The Problem

Frequently, we use C<Data::Dumper> to dump out some variables while debugging.
When this happens, we often do this:

 use Data::Dumper;
 warn Dumper($foo, $bar, $baz);

And we get simple output like:

 $VAR1 = 3;
 $VAR2 = 2;
 $VAR3 = 1;

While this is usually what we want, this can be confusing if we forget which
variable corresponds to which variable printed.  To get around this, there is
an extended interface to C<Data::Dumper>:

  warn Data::Dumper->Dump(
    [$foo, $bar, $baz],
    [qw/*foo *bar *baz/]
  );

This provides much more useful output.

  $foo = 3;
  $bar = 2;
  $baz = 1;

(There's more control over the output than what I've shown.)

You can even use this to output more complex data structures:

  warn Data::Dumper->Dump(
    [$foo, \@array],
    [qw/*foo *array/]
  );

And get something like this:

  $foo = 3;
  @array = (
             8,
             'Ovid'
           );

Unfortunately, this can involve a lot of annoying typing.

  warn Data::Dumper->Dump(
    [$foo, \%this, \@array, \%that],
    [qw/*foo *that *array *this/]
  );

You'll also notice a typo in the second array ref which can cause great
confusion while debugging.

=head2 The Solution

With C<Data::Dumper::Simple> you can do this instead:

  use Data::Dumper::Simple.
  warn Dumper($scalar, @array, %hash);

Note that there's no need to even take a reference to the variables.  The 
output of the above resembles this (sample data, of course):

  $scalar = 'Ovid';
  @array = (
             'Data',
             'Dumper',
             'Simple',
             'Rocks!'
           );
  %hash = (
            'it' => 'does',
            'I' => 'hope',
            'at' => 'least'
          );

Taking a reference to an array or hash is effectively a no-op, but a scalar
containing a reference works as expected:

 my $foo   = { hash => 'ref' };
 my @foo   = qw/foo bar baz/;
 warn Dumper ($foo, \@foo);

Produces:

 $foo = {
   'hash' => 'ref'
 };
 @foo = (
   'foo',
   'bar',
   'baz'
 );

This is to ensure that similarly named variables are properly disambiguated in
the output.

=head1 EXPORT

The only thing exported is the Dumper() function.

Well, actually that's not really true.  Nothing is exported.  However, a source
filter is used to automatically rewrite any apparent calls to C<Dumper()> so
that it just Does The Right Thing.

=head1 SEE ALSO

=over 4

=item * 
Data::Dumper - Stringified perl data structures

=item *
Filter::Simple - Simplified source filtering

=back

=head1 BUGS AND CAVEATS

This module uses a source filter.  If you don't like that, don't use this.

There are no known bugs but there probably are some as this is B<Alpha Code>.
As for limitations, do not try to call C<Dumper()> with a subroutine in the
argument list:

  Dumper($foo, some_sub()); # Bad!

The filter gets confused by the parentheses.  Your author was going to fix this
but it became apparent that there was no way that C<Dumper()> could figure out
how to name the return values from the subroutines, thus ensuring further
breakage.  So don't do that.

Getting really crazy by using multiple enreferencing will confuse things (e.g.,
C<\\\\\\$foo>), don't do that, either.  I might use C<Text::Balanced> at some
point to fix this if it's an issue.

List and hash slices are not supported at this time.

Note that this is not a drop-in replacement for C<Data::Dumper>.  If you
need the power of that module, use it.

=head1 AUTHOR

Curtis "Ovid" Poe, E<lt>eop_divo_sitruc@yahoo.comE<gt>

Reverse the name to email me.

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Curtis "Ovid" Poe

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
