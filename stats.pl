#!/usr/bin/env perl
use v5.14;
use JSON;

sub firstline { local (@ARGV) = $_[0]; my $c = <>; chomp($c); $c }

my %stats = (
    # number of all entities
    entities => [ "all.ids.count", \&firstline ],

    # number of publication entities
    publications => [ "all.publications.ids.count", \&firstline ],

    # number of publication types
    pubtypes => [ "all.pubtypes",
                  sub { local (@ARGV) = @_; @_=<>; scalar @_ } ],
);

my $summary = {};

foreach my $date ( sort grep { -d $_ } glob('20??????') ) {
    my $isodate = $date;
    $isodate =~ s/(....)(..)(..)/$1-$2-$3/;

    $summary->{$isodate} //= {};

    $summary->{$isodate}{md5} = firstline($_)
        for grep { -e $_ } ("$date/wikidata-$date-all.md5");

    if (-e "$date/wikidata-$date-all.classes.csv" and
        !-e "$date/wikidata-$date-all.classes.count") {
        system("make $date/wikidata-$date-all.classes.count");
    }

    $summary->{$isodate}{classes} = firstline($_)
        for grep { -e $_ } ("$date/wikidata-$date-all.classes.count");

    foreach my $name (keys %stats) {
        my ($suffix, $count) = @{$stats{$name}};

        my $file = "$date/wikidata-$date-$suffix";
        if (-e $file) {
            $summary->{$isodate}{$name} = $count->($file);
        }
    }
}

say encode_json($summary);
