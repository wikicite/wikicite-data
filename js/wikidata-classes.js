#!/usr/bin/env node

/**
 * Extract item, superclass pairs in CSV format from Wikidata dump.
 */

const { getEntitiesStream } = require('wikibase-dump-filter')
const { propertyClaims: simplifyPropertyClaims } = require('wikibase-sdk').simplify

getEntitiesStream(process.stdin)
.filterAndMap(item => {
  if (item.type === 'item' && item.claims && item.claims.P279) {
    return simplifyPropertyClaims(item.claims.P279)
      .map(qid => item.id + ',' + qid)
      .join('\n') + '\n'
  }
})
.pipe(process.stdout)