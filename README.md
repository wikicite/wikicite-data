# WikiCite data

This repository contains scripts to extract, transform, and analyze bibliographic data from Wikidata.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Node](https://img.shields.io/badge/node-%3E=%20v6.4.0-brightgreen.svg)](http://nodejs.org)

Source code is based and makes use of the modules [wikidata-filter](https://www.npmjs.com/package/wikidata-filter)
and [wikidata-sdk](https://www.npmjs.com/package/wikidata-sdk) by Maxime Lathuilière.

## Usage

    bzcat latest-all.json.bz2 | ./bin/wikicite-extract > wikicite.ndjson

## License

[MIT](LICENSE.md)
