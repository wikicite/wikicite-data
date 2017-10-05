#!/usr/bin/env perl
use v5.14;

sub dates { sort grep { -d $_ } glob('20??????') }

sub count { local (@ARGV) = $_[0]; my $c = <>; chomp($c); $c }

sub summary {
    my ($suffix, $name) = @_;
    open my $fh, ">", "$name.count.csv";
    say $fh "date,$name";
    say $fh join "\n", map {
            my $file = "$_/wikidata-$_-$suffix";
            my $date = $_;
            s/(....)(..)(..)/$1-$2-$3/;
            -e $file ?  "$_,".count($file) : ();
        } dates;
    close $fh;
}

# number of all entities
summary("all.ids.count" => "entities");

# number of publication entities
summary("all.wikicite.ids.count" => "publications");
