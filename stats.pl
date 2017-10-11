#!/usr/bin/env perl
use v5.14;
use JSON::PP;

# read file without last newline
sub slurp { local (@ARGV) = $_[0]; chomp(my @a=<>); join "\n", @a; }

my $stats = decode_json(slurp('stats.json'));

foreach my $date ( sort grep { -d $_ } glob('20??????') ) {
    my $isodate = $date;
    $isodate =~ s/(....)(..)(..)/$1-$2-$3/;

    my $stat = $stats->{$isodate} //= {};
    my $pubs = $stat->{publications} //= {};

    $stat->{md5} = slurp($_)
        for grep { -e $_ } ("$date/wikidata-$date-all.md5");

    $stat->{entities} = 1*slurp($_)
        for grep { -e $_ } ("$date/wikidata-$date-all.ids.count");

    $stat->{size} = (stat $_)[7]
        for grep { -e $_ } ("$date/wikidata-$date-all.json.gz");

    $pubs->{size} = (stat $_)[7]
        for grep { -e $_ } ("$date/wikidata-$date-publications.ndjson.gz");

    $pubs->{citations} = system('wc','-l',$_)
        for grep { -e $_ } ("$date/wikidata-$date-citations.csv");

    # number of publication entities
    $pubs->{items} = 1*slurp($_)
        for grep { -e $_ } ("$date/wikidata-$date-publications.ids.count");

    if (-e "$date/wikidata-$date.classes.csv" and
        !-e "$date/wikidata-$date.classes.count") {
        system("make $date/wikidata-$date.classes.count");
    }

    $stat->{classes} = 1*slurp($_)
        for grep { -e $_ } ("$date/wikidata-$date.classes.count");

    $stat->{pubtypes} = do { local (@ARGV) = $_; @_=<>; scalar @_ }
        for grep { -e $_ } ("$date/wikidata-$date.pubtypes");
}

# Serialize in same JSON form like `jq -S`
open my $fh, '>', 'stats.json';
print $fh JSON::PP->new->canonical->indent->indent_length(2)->space_after->encode($stats);
