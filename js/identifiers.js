#!/usr/bin/env node

const fs = require('fs')
const wdk = require('wikidata-sdk')
const { parser, serializer } = require('wikidata-filter')
const tsv = row => row.join("\t") + "\n"

const identifierProperties = JSON.parse(fs.readFileSync('identifier-properties.json'))

// helper functions
const pids = claims => Object.keys(claims).sort((a,b) => a.substr(1) - b.substr(1))
const identifierPids = new Set(pids(identifierProperties))

parser(process.stdin, { type: 'item' })
.filter(entity => {
  const claims = entity.claims || {}
  const id = entity.id
  let rows = []
  for (let p in claims) {
    if (identifierPids.has(p)) {
      const values = wdk.simplify.propertyClaims(claims[p])
      values.forEach(v => {
        console.log(`${id} ${p} ${v}`)
      })
    }
  }
})

