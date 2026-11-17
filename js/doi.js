#!/usr/bin/env node

const { getEntitiesStream } = require('wikibase-dump-filter')
const { propertyClaims: simplifyPropertyClaims } = require('wikibase-sdk').simplify

// get all items with DOI statement (http://www.wikidata.org/entity/P356)
// and print QID, DOI as comma-separated values
getEntitiesStream(process.stdin)
  .filterAndMap(item => {
    if (item.claims && item.claims.P356) {
      return simplifyPropertyClaims(item.claims.P356)
        .map(doi => item.id + ',' + doi + '\n')
        .join('')
    }
  })
  .pipe(process.stdout)
