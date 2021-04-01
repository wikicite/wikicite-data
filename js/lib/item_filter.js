// const wdk = require('wikidata-sdk')
const wdClaims = require('./claims.js')

module.exports = function (classes) {
  // store classes in a set for fast lookup
  const classSet = new Set(classes)

  return (item) => {
    if (item.type !== 'item' || !item.claims || !item.claims.P31) return null

        // simplify P31 statements only to quickly reject
    const P31 = item.claims.P31.filter(wdClaims.truthy)
    if (!isInstanceOfAny(P31, classSet)) return null

    return item
  }
}

const isInstanceOfAny = (P31, classSet) => {
  for (const claim of P31) {
    if ('datavalue' in claim.mainsnak) {
      const qid = 'Q' + claim.mainsnak.datavalue.value['numeric-id']
      if (classSet.has(qid)) return true
    }
  }
  return false
}
