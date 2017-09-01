#!/usr/bin/env node

const split = require('split')
const filter = require('wikidata-filter/lib/filter')
const getClasses = require('./lib/get_classes')

getClasses('Q732577', (classes) => {
    const itemFilter = require('./lib/item_filter')(classes)

    process.stdin
    .pipe(split())
    .pipe(filter(itemFilter))
    .pipe(process.stdout)
})
