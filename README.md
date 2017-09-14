# WikiCite data

This repository contains scripts to extract, transform, and analyze bibliographic data from Wikidata.

[![License](https://img.shields.io/badge/license-CC0-blue.svg)](https://creativecommons.org/publicdomain/zero/1.0/)

*the current state of this project is experimental*

## Overview

Bibliographic data can be extracted from Wikidata dumps which are provided weekly at <https://dumps.wikimedia.org/wikidatawiki/entities/> as documented at <https://www.wikidata.org/wiki/Wikidata:Database_download>. Old JSON dumps are archived at Internet Archive starting from October 2014. Then Wikidata JSON dump format was introduced in July 2014 so data from between February 2013 until would require additional preprocessing.

Processing Wikidata dumps requires storage, processing time, and knowledge. With the scripts in this repository, Wikidata dumps can be pre-processed and provided in simplified form, more suitable for use of bibliographic data from Wikidata. The repository further contains checksums, lists of publication types, and statistics derived from Wikidata dumps. Full dumps *are not included* but must be shared by other means (IPFS anyone?). 

## Requirements

The current scripts require the following technologies:

* standard Unix command line tools (`bash`, `make`, `wget`, `gzip`, `zcat`)
* node >= 6.4.0, npm, and packages listed in `packages.json` [![Node](https://img.shields.io/badge/node-%3E=%20v6.4.0-brightgreen.svg)](http://nodejs.org)
    * [wikidata-filter](https://www.npmjs.com/package/wikidata-filter) and [wikidata-sdk](https://www.npmjs.com/package/wikidata-sdk) by Maxime Lathuilière
* jq

## Usage

### Download dumps

The `download-dump` script can be used to download a full, compressed JSON dump from <https://dumps.wikimedia.org/wikidatawiki/entities/> and place it in a subdirectory named by date of the dump:

    ./download-dump 20170626

Old dumps must be downloaded manually from Internet Archive.

A MD5 hash of the extracted dump can be computed like this:

    make 20170626/wikidata-20170626-all.md5

The MD5 hash is commited in git for reference.

The number of items can be counted as following, it is also committed in git:

    make 20170626/wikidata-20170626-all.ids.count

## Extract publication types

To find out which Wikidata items refer to bibliographic objects, we must extract all subclasses of [Q732577](http://www.wikidata.org/entity/Q732577) (publication). The class hierarchy must be derived from the JSON dump because it will likely have been changed in meantime.

First extract all truthy subclass-of statements:

    make 20170626/wikidata-20170626-all.classes.csv

Then get all subclasses of Q732577 and Q191067 (the latter was missing as subclass of the former until mid-September 2017):

    make 20170626/wikidata-20170626-all.pubtypes

The list of publication types is sorted and commited for reference.

## Extract bibliographic items

Extract all bibliographic items, with simplified truthy statements, based on the list of publication types:

    make 20170626/wikidata-20170626-all.wikicite.ndjson.gz

**FIXME:**

* Author names are not sorted yet
* Claims with special value "unknown" are not included although this might be useful

## Extract labels

The wikicite dump does not contain information about non-bibliographic items such as people and places. To further make use of the data you likely need labels.

    make 20170626/wikidata-20170626-all.labels.ndjson

Uncompressed label files tend do get large so compression or reduction to a selected language may be added later.

## Convert to other bibliographic formats

To be done (especially CSL-JSON and MARCXML)

## See also

* Live data can be queried from Wikidata with SPARQL at <https://query.wikidata.org/>.

* [Citation.js](https://citation.js.org/) can convert Wikidata items to several bibliographic data formats

* [Zotero can convert Wikidata items](https://www.wikidata.org/wiki/Wikidata:Zotero) to several bibliographic data formats

* [librarybase-scripts](https://github.com/harej/librarybase-scripts) by James Hare for bibliographic metadata work on Wikidata

* <http://wikicite.org/>

## License

[CC0](LICENSE.md)
