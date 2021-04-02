#!/usr/bin/env node

const { getEntitiesStream } = require('wikibase-dump-filter')
const { propertyClaims: simplifyPropertyClaims } = require('wikibase-sdk').simplify

getEntitiesStream(process.stdin)    
  .filterAndMap(item => {
    if (item.claims && item.claims.P2860) {
      return simplifyPropertyClaims(item.claims.P2860)
      .map(qid => item.id + ',' + qid + '\n')
      .join('')
    }
  })
  .pipe(process.stdout)
