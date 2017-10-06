#!/usr/bin/env perl
use v5.14;

sub dates { sort grep { -d $_ } glob('20??????') }

sub count { local (@ARGV) = $_[0]; my $c = <>; chomp($c); $c }

sub summary {
    my ($suffix, $name, $count) = @_;
    open my $fh, ">", "summary/$name.count.csv";
    say $fh "date,$name";
    say $fh join "\n", map { ## no critic
            my $file = "$_/wikidata-$_-$suffix";
            my $date = $_;
            s/(....)(..)(..)/$1-$2-$3/;
            -e $file ?  "$_,".$count->($file) : ();
        } dates;
    close $fh;
}

# number of all entities
summary("all.ids.count" => "entities", \&count);

# number of publication entities
summary("all.publications.ids.count" => "publications", \&count);

# number of publication types
summary("all.pubtypes" => "pubtypes", sub { local (@ARGV) = @_; @_=<>; scalar @_ });

