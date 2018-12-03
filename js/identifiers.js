#!/usr/bin/env node

const fs = require('fs')
const wdk = require('wikidata-sdk')
const { parser, serializer } = require('wikidata-filter')
const tsv = row => row.join("\t") + "\n"

const identifierProperties = JSON.parse(fs.readFileSync('identifier-properties.json'))

// helper functions
const pids = claims => Object.keys(claims).sort((a,b) => a.substr(1) - b.substr(1))
const identifierPids = pids(identifierProperties)

// header row
process.stdout.write(tsv(['qid',...identifierPids]))

parser(process.stdin, { type: 'item' })
.filter(entity => {
  const claims = entity.claims || {}
  const claimPids = new Set(Object.keys(claims))
  const row = identifierPids.map( p => {
    if (claimPids.has(p)) {
      let values = wdk.simplify.propertyClaims(claims[p])
      return values.join('\xa0') // separate repeated ids by NBSP
    } else {
      return ''
    }
  })
  return tsv([entity.id, ...row])
})
.pipe(process.stdout)

