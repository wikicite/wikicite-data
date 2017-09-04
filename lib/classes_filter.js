const parseLine = require('wikidata-filter/lib/parse_line')

const claims = require('./claims.js')

module.exports = function (line) {
    const item = parseLine(line)

    if (!item || item.type != 'item') return null
    if (!item.claims || !item.claims.P279) return null

    const id = item.id

    return claims.truthy(item.claims.P279)
            .filter(claims.known)
            .map(claims.simplify.itemValue)
            .map( (qid) => { return id + ',' + qid } )
            .join('\n') + '\n'
} 
