
# MD5 sum of decompressed files
%.md5: %.json.gz
	zcat $< | md5sum | awk '{print $$1}' > $@

# number of entities
%.ids.count: %.json.gz
	zcat $< | wc -l | awk '{print $$1-2}'> $@
%.ids.count: %.ndjson.gz
	zcat $< | wc -l | awk '{print $$1-2}'> $@

# comma-separated truthy class-superclass relations
%.classes.csv: %.json.gz
	zcat $< | ./wikidata-classes.js > $@

# publication classes
%.pubtypes: %.classes.csv
	./subclasses.js Q732577 < $< | sort > $@

# bibliographic items
%.wikicite.ndjson.gz: %.json.gz %.pubtypes
	zcat $< | ./wikicite-extract.js $(basename $(basename $<)).pubtypes | gzip -9 > $@ 

# entity labels
%.labels.ndjson: %.json.gz
	zcat $< | head -n-1 | tail -n+2 | sed 's/,$$//' | \
		jq -c '{id:.id,labels:(.labels|map_values(.value))}' > $@


# clean up JavaScript code
standard:
	./node_modules/standard/bin/cmd.js --fix *.js lib/*.js

