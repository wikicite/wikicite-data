#!/usr/bin/env node

const fs = require('fs')
const split = require('split')
const { parser, serializer, filter } = require('wikidata-filter')
const itemFilter = require('./lib/item_filter')

var classes = []

fs.createReadStream(process.argv[2])
  // read list of class qids from file
  .pipe(split())
  .on('data', (qid) => {
    if (qid.match(/^Q[0-9]+$/)) {
      classes.push(qid)
    }
  })
  // filter and simplify instance items
  .on('close', () => {
    parser(process.stdin)
    .filter(itemFilter(classes))
    .filter(filter({'simplified':true}))
    .filter(serializer)
    .pipe(process.stdout)
  })
