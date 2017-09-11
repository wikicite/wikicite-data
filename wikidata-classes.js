#!/usr/bin/env node

/**
 * Extract item, superclass pairs in CSV format from Wikidata dump.
 */

const { parser, filter } = require('wikidata-filter')
const { simplify } = require('wikidata-sdk')

parser(process.stdin)
.filter(filter({type: 'item'}))
.filter(item =>
  item.claims && item.claims.P279
    ? simplify.propertyClaims(item.claims.P279)
    .map(qid => item.id + ',' + qid)
    .join('\n') + '\n'
  : null
)
.pipe(process.stdout)
