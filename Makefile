LOGFILE=make.log
WDFILTER=./node_modules/wikibase-dump-filter/bin/wikibase-dump-filter

# keep intermediate targets
.SECONDARY:

# MD5 sum of decompressed files
%.md5: %.json.gz
	zcat $< | md5sum | awk '{print $$1}' > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# number of entities
%.ids.count: %.json.gz
	zcat $< | wc -l | awk '{print $$1-2}'> $@
	@echo `date +%s:` $@ >> ${LOGFILE}

%.ids.count: %.ndjson.gz
	zcat $< | wc -l > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# comma-separated truthy class-superclass relations
wikidata-%.classes.csv: wikidata-%-all.json.gz
	zcat $< | ./js/wikidata-classes.js > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

wikidata-%.instances.csv: wikidata-%-all.json.gz
	zcat $< | ./js/wikidata-instances.js > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

wikidata-%.classes.count: wikidata-%.classes.csv
	awk -F, '{print $$1;print $$2}' $< | sort | uniq | wc -l > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# properties
wikidata-%-properties.ndjson.gz: wikidata-%-all.json.gz
	zcat $< | ${WDFILTER} --type property | gzip -9 > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# publication classes
wikidata-%.pubtypes: wikidata-%.classes.csv
	./js/subclasses.js Q732577 Q191067 < $< | sort > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# bibliographic items
wikidata-%-publications.ndjson.gz: wikidata-%-all.json.gz wikidata-%.pubtypes
	zcat $< | ./js/wikicite-extract.js $(word 2,$^) | gzip -9 > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# properties used in bibliographic items
property-count-per-publication-%.csv: wikidata-%-publications.ndjson.gz
	zcat $< | jq -r '.claims|keys[]' | ./pl/count-ids.pl > $@

# DOIs of bibliographic items
wikidata-%-dois.csv: wikidata-%-publications.ndjson.gz
	zcat $< | ./js/doi.js > $@

# citations
wikidata-%-citations.csv: wikidata-%-publications.ndjson.gz
	zcat $< | ./js/citations.js > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# identifiers
wikidata-%-identifiers.tsv.gz: wikidata-%-all.json.gz
	zcat $< | ./js/identifiers.js | gzip -9 > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# entity labels
%.labels.ndjson.gz: %.json.gz
	zcat $< | head -n-1 | tail -n+2 | sed 's/,$$//' | \
		jq -c '{id:.id,labels:(.labels|map_values(.value))}' | gzip -9 > $@
	echo $@ >> ${LOGFILE} 

# current identifier properties
identifier-properties.json: 
	./js/identifier-properties.js > $@

# create statistics
.PHONY: stats.json identifier-properties.json
stats: stats.json
stats.json:
	./stats.pl

dataflow.png: dataflow.dot
	dot dataflow.dot -Tpng -odataflow.png

# clean up JavaScript code
standard:
	./node_modules/standard/bin/cmd.js --fix *.js lib/*.js

