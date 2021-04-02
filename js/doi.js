#!/usr/bin/env node

const fs = require('fs')
const { parseEntitiesStream } = require('wikibase-dump-filter')

// get all items with DOI statement (http://www.wikidata.org/entity/P356)
parserEntitiesStream(process.stdin, { type: 'both' })
.filter( item => item.claims && item.claims.P356 ? item : null )
// print QID, DOI as comma-separated values
.filter(
  item => item.claims.P356.map( doi => item.id + ',' + doi + '\n').join('')
)
.pipe(process.stdout)
