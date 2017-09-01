const parseLine = require('wikidata-filter/lib/parse_line')
const wdk = require('wikidata-sdk')

module.exports = function (types) {

	// store types in an object for fast lookup
	const typeMap = types.reduce(function(map, qid) {
  		map[qid] = true;
  		return map;
	}, {});

    return (line) => {
        const item = parseLine(line)
        if (!item || item.type != 'item') return null
		if (!item.claims.P31) return null

        try { // https://github.com/maxlath/wikidata-sdk/issues/17
	        simplify(item, 'claims')
        } catch (e) {
            return null
        }

		if (!filterType(item.claims.P31, typeMap)) return null

		simplify(item, 'labels')
	    simplify(item, 'descriptions')
    	simplify(item, 'aliases')
		simplify(item, 'sitelinks')

        return JSON.stringify(item) + '\n'
    }
}

const filterType = (P31, types) => {
	for(var i=0; i<P31.length; i++) {
		if (P31[i] in types) return true;
	}
	return false
}

const simplify = (item, attr) => {
  if (item[attr]) {
    item[attr] = wdk.simplify[attr](item[attr])
  }
}
