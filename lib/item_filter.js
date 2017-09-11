const wdk = require('wikidata-sdk')
const wdClaims = require('./claims.js')

module.exports = function (classes) {
  // store classes in an object for fast lookup
  const classMap = classes.reduce(function (map, qid) {
    map[qid] = true
    return map
  }, {})

  return (item) => {
    if (item.type !== 'item' || !item.claims || !item.claims.P31) return null

        // simplify P31 statements only to quickly reject
    const P31 = item.claims.P31.filter(wdClaims.truthy)
    if (!isInstanceOfAny(P31, classMap)) return null

    return item
  }
}

const isInstanceOfAny = (P31, classes) => {
  for (var i = 0; i < P31.length; i++) {
    if ('datavalue' in P31[i].mainsnak) {
      const qid = 'Q' + P31[i].mainsnak.datavalue.value['numeric-id']
      if (qid in classes) return true
    }
  }
  return false
}
