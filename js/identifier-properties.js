#!/usr/bin/env node

// Get Wikidata:Identifier properties (any datatype)
const wdk = require('wikibase-sdk')
const request = require('request-promise-native')

const query = `
  SELECT DISTINCT ?p ?pLabel ?template {
    ?p wdt:P31/wdt:P279* wd:Q19847637 .
    ?p wikibase:propertyType ?type .
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
    OPTIONAL { ?p wdt:P1921 ?template }
  }`
const uri = wdk.sparqlQuery(query)

request({uri, json: true})
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
