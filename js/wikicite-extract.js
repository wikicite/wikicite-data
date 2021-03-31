#!/usr/bin/env node

const fs = require('fs')
const { getEntitiesStream, filterFormatAndSerialize } = require('wikibase-dump-filter')
const { isItemId } = require('wikibase-sdk')
const itemFilter = require('./lib/item_filter')

const classes = fs.readFileSync(process.argv[2])
  .toString()
  .split('\n')
  .filter(isItemId)

getEntitiesStream(process.stdin)
.filterAndMap(itemFilter(classes))
.filterAndMap(filterFormatAndSerialize({'simplified': true}))
.pipe(process.stdout)
