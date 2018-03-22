LOGFILE=make.log
WDFILTER=./node_modules/wikidata-filter/bin/wikidata-filter

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

# DOIs of bibliographic items
wikidata-%-dois.csv: wikidata-%-publications.ndjson.gz
	zcat $< | ./js/doi.js > $@

# citations
wikidata-%-citations.csv: wikidata-%-publications.ndjson.gz
	zcat $< | ./js/citations.js > $@
	@echo `date +%s:` $@ >> ${LOGFILE}

# entity labels
%.labels.ndjson: %.json.gz
	zcat $< | head -n-1 | tail -n+2 | sed 's/,$$//' | \
		jq -c '{id:.id,labels:(.labels|map_values(.value))}' > $@
	echo $@ >> ${LOGFILE} 

# create statistics
.PHONY: stats.json
stats: stats.json
stats.json:
	./stats.pl

dataflow.png: dataflow.dot
	dot dataflow.dot -Tpng -odataflow.png

# clean up JavaScript code
standard:
	./node_modules/standard/bin/cmd.js --fix *.js lib/*.js

