#!/usr/bin/env node

const fs = require('fs')
const split = require('split')


var classes = []

fs.createReadStream(process.argv[2])
  .pipe(split())
  .on('data', (qid) => {
      if (qid.match(/^Q[0-9]+$/)) {
          classes.push(qid)
      }
  })
  .on('close', () => {

      const filter = require('wikidata-filter/lib/filter')
      const itemFilter = require('./lib/item_filter')(classes)

      process.stdin
        .pipe(split())
        .pipe(filter(itemFilter))
        .pipe(process.stdout)
  })
