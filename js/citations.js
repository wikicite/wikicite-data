#!/usr/bin/env node

const fs = require('fs')
const { parser } = require('wikidata-filter')

parser(process.stdin)    
  .filter(item => item.claims  
      ? (item.claims.P2860 || [])
        .map(qid => item.id + ',' + qid + '\n').join('')
    : null
  )
  .pipe(process.stdout)
