LOGFILE=make.log

# MD5 sum of decompressed files
%.md5: %.json.gz
	zcat $< | md5sum | awk '{print $$1}' > $@ && echo $@ >> ${LOGFILE}

# number of entities
%.ids.count: %.json.gz
	zcat $< | wc -l | awk '{print $$1-2}'> $@ && echo $@ >> ${LOGFILE}
%.ids.count: %.ndjson.gz
	zcat $< | wc -l > $@ && echo $@ >> ${LOGFILE}

# comma-separated truthy class-superclass relations
%.classes.csv: %.json.gz
	zcat $< | ./wikidata-classes.js > $@ && echo $@ >> ${LOGFILE}

%.classes.count: %.classes.csv
	awk -F, '{print $$1;print $$2}' $< | sort | uniq | wc -l > $@

# publication classes
%.pubtypes: %.classes.csv
	./subclasses.js Q732577 Q191067 < $< | sort > $@ && echo $@ >> ${LOGFILE}

# bibliographic items
%.publications.ndjson.gz: %.json.gz %.pubtypes
	zcat $< | ./wikicite-extract.js $(basename $(basename $<)).pubtypes \
		| gzip -9 > $@ && echo $@ >> ${LOGFILE}

# entity labels
%.labels.ndjson: %.json.gz
	zcat $< | head -n-1 | tail -n+2 | sed 's/,$$//' | \
		jq -c '{id:.id,labels:(.labels|map_values(.value))}' > $@ \
	&& echo $@ >> ${LOGFILE} 

# create statistics
.PHONY: stats.json
stats: stats.json
stats.json:
	./stats.pl | jq -S . > $@

dataflow.png: dataflow.dot
	dot dataflow.dot -Tpng -odataflow.png

# clean up JavaScript code
standard:
	./node_modules/standard/bin/cmd.js --fix *.js lib/*.js

