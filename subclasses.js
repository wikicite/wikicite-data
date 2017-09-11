#!/usr/bin/env node

const split = require('split')

// get root item qid(s) as command line arguments
var nodes = process.argv.slice(2)

// build index by reading CSV (child,parent) from stdin
var children = {}
process.stdin
    .pipe(split())
    .on('data', (line) => {
        const [child, id] = line.split(',')
        if (children[id]) {
            children[id].push(child)
        } else {
            children[id] = [child]
        }
    })
    .on('close', subclasses)

// print all transitively reachable items
function subclasses() {
    var visited = {}
    while (nodes.length > 0) {
        var qid = nodes.pop()
        if (visited[qid]) continue
        visited[qid] = true
        process.stdout.write(qid + "\n")
        if (children[qid]) {
            nodes.push(...children[qid])
        }
    }
}
