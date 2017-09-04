const parseLine = require('wikidata-filter/lib/parse_line')
const wdk = require('wikidata-sdk')
const wdClaims = require('./claims.js')

module.exports = function (classes) {

	// store classes in an object for fast lookup
	const classMap = classes.reduce(function(map, qid) {
  		map[qid] = true
  		return map
	}, {})

    return (line) => {
        const item = parseLine(line)
        if (!item || item.type != 'item') return null
		if (!item.claims || !item.claims.P31) return null

        const P31 = item.claims.P31.filter(wdClaims.truthy)
		if (!isInstanceOfAny(P31, classMap)) return null

        // limit to truthy statements (TODO: wikidata-sdk does not do this?)
        for (let key in item.claims) {
            if (item[key]) {
                item[key] = item[key].filter(wdClaims.truthy)
            }
            if (!item[key] || !item[key].length) {
                delete item[key]
            }
        }

	    simplify(item, 'claims')
		simplify(item, 'labels')
	    simplify(item, 'descriptions')
    	simplify(item, 'aliases')
		simplify(item, 'sitelinks')

        return JSON.stringify(item) + '\n'
    }
}

const isInstanceOfAny = (P31, classes) => {
	for(var i=0; i<P31.length; i++) {
        if ('datavalue' in P31[i].mainsnak) {
            const qid = 'Q'+P31[i].mainsnak.datavalue.value['numeric-id']                
    		if (qid in classes) return true
        }
	}
	return false
}

const simplify = (item, attr) => {
  if (item[attr]) {
    item[attr] = wdk.simplify[attr](item[attr])
  }
}
