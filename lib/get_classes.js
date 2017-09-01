const wdk = require('wikidata-sdk')
const request = require('request')

module.exports = function (root, callback) {
    const sparql = "SELECT ?type WHERE { ?type wdt:P279* wd:"+root+" }"
    const url = wdk.sparqlQuery(sparql)

    request(url, (error, response, body) => {
        const results = JSON.parse(body).results
        const classes = results.bindings.map( (value) => {
            return value.type.value.substr(31)
        })
        callback(classes)
    })
}
