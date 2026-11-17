#!/usr/bin/env node

// Get Wikidata:Identifier properties (any datatype)
const wdk = require('wikibase-sdk')({
  instance: 'https://www.wikidata.org',
  sparqlEndpoint: 'https://query.wikidata.org/sparql'
})

const query = `
  SELECT DISTINCT ?p ?pLabel ?template {
    ?p wdt:P31/wdt:P279* wd:Q19847637 .
    ?p wikibase:propertyType ?type .
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
    OPTIONAL { ?p wdt:P1921 ?template }
  }`
const uri = wdk.sparqlQuery(query)

fetch(uri, {
  headers: {
    Accept: 'application/sparql-results+json',
    'User-Agent': 'wikicite-data (https://github.com/wikicite/wikicite-data)'
  }
})
  .then(res => {
    if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`)
    return res.json()
  })
  .then(wdk.simplify.sparqlResults)
  .then(props => {
    props = props.reduce( 
      (obj, prop) => {
        obj[prop.p.value] = { 
            template: prop.template,
            label: prop.p.label
        }
        return obj
      }, {})
    console.log(JSON.stringify(props,null, 2))
  })
