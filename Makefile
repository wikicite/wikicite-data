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

# create summaries
summary:
	./summaries.pl
all.ids.count:
	./summaries.pl
pubs.ids.count:
	./summaries.pl

# clean up JavaScript code
standard:
	./node_modules/standard/bin/cmd.js --fix *.js lib/*.js

