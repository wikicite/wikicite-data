#!/usr/bin/env node

const fs = require('fs')
const { parser } = require('wikidata-filter')

// get all items with DOI statement (http://www.wikidata.org/entity/P356)
parser(process.stdin)  
.filter( item => item.claims && item.claims.P356 ? item : null )
// print QID, DOI as comma-separated values
.filter(
  item => item.claims.P356.map( doi => item.id + ',' + doi + '\n').join('')
)
.pipe(process.stdout)
