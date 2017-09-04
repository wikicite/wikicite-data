# Each rule is duplicated for bzip2 and for gzip compression


# MD5 sum of decompressed files
%.md5: %.json.bz2
	bzcat $< | md5sum | awk '{print $$1}' > $@

%.md5: %.json.gz
	zcat $< | md5sum | awk '{print $$1}' > $@


# comma-separated truthy class-superclass relations
%.classes.csv: %.json.bz2
	bzcat $< | ./wikidata-classes.js > $@

%.classes.csv: %.json.gz
	zcat $< | ./wikidata-classes.js > $@


# publication classes
%.pubtypes: %.classes.csv
	./subclasses.js Q732577 < $< | sort > $@


# bibliographic items
%.wikicite.ndjson.bz2: %.json.gz %.pubtypes
	zcat $< | ./wikicite-extract.js $(basename $(basename $<)).pubtypes | bzip2 -9 > $@ 
 
%.wikicite.ndjson.bz2: %.json.bz2 %.pubtypes
	bzcat $< | ./wikicite-extract.js $(basename $(basename $<)).pubtypes | bzip2 -9 > $@


# entity labels
%.labels.ndjson: %.json.bz2
	bzcat $< | head -n-1 | tail -n+2 | sed 's/,$$//' | \
		jq -c '{id:.id,labels:(.labels|map_values(.value))}' > $@
