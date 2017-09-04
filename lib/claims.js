module.exports = {

    // filter truthy claims
    truthy: (claims) => {
        var filtered = []

        for (let i=0; i<claims.length; i++) {
            const rank = claims[i].rank
            if (rank == "preferred") {
                return [claims[i]]
            } else if (rank != "deprecated") {
                filtered.push(claims[i])
            }
        }

        return filtered
    },

    // check whether a claim has known value
    known: (claim) => {
        return 'datavalue' in claim.mainsnak
    },

    simplify: {
        // simplify claim with datatype wikidata-item
        itemValue: (claim) => {
            return 'Q'+claim.mainsnak.datavalue.value['numeric-id']
        }
    }
}
