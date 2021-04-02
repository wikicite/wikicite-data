#!/usr/bin/env node

/**
 * Extract item, class pairs in CSV format from Wikidata dump.
 */

const { parseEntitiesStream, filterFormatAndSerialize } = require('wikibase-dump-filter')
const { simplify } = require('wikibase-sdk')

parseEntitiesStream(process.stdin, { type: 'both' })
.filter(filterFormatAndSerialize({type: 'item'}))
.filter(item =>
  item.claims && item.claims.P31
    ? simplify.propertyClaims(item.claims.P31)
    .map(qid => item.id + ',' + qid)
    .join('\n') + '\n'
  : null
)
.pipe(process.stdout)
