#!/usr/bin/env node

const split = require('split')
const filter = require('wikidata-filter/lib/filter')
const classesFilter = require('./lib/classes_filter')

process.stdin
.pipe(split())
.pipe(filter(classesFilter))
.pipe(process.stdout)
