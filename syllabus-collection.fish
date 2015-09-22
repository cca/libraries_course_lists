#!/usr/bin/env fish
# Syllabus Collection is a bit special so gets its own script
# usage:
#   ./syllabus-collection.fish informer.csv

# load log function
source log.fish

set --local dept SYLLABUS
set --local dir data
set --local pw (jq -r '.password' ~/.equellarc)
set --local un (jq -r '.username' ~/.equellarc)
cp $argv[1] $dir/$dept.csv
set --local filename $dir/$dept.csv
# need to trim header row for get-columns
tail -n +2 $dir/$dept.csv > tmpfile
set --local logfile logs/(date "+%Y-%m-%d")-syllabus.txt

# create CSVs for all taxonomies
./get-columns.fish tmpfile SYLLABUS
rm tmpfile
# create a couple CSVs not made in any other steps
# XList IDs, deleting the empty row with sed
csvcut -c 7 $filename | sort | uniq | tail -n +2 | sed -e '/""/d' > $dir/$dept-xlist.csv
and echo "Wrote $dept XList IDs CSV…"
csvcut -c 2 $filename | sort | uniq | tail -n +2 > $dir/$dept-dept-codes.csv
and echo "Wrote $dept department codes CSV…"

# update all taxonomies
# main course list
set uuid (eq tax --name "$dept - COURSE LIST" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-course-list-taxo.csv >> $logfile
end

# course titles
set uuid (eq tax --name "$dept - course titles" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-course-titles.csv >> $logfile
end

# faculty names
set uuid (eq tax --name "$dept - faculty" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-faculty-names.csv >> $logfile
end

# course names e.g. INDIV-101
set uuid (eq tax --name "$dept - course names" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-courses.csv >> $logfile
end

# course sections
set uuid (eq tax --name "$dept - course sections" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-section-names.csv >> $logfile
end

# Xlist IDs
set uuid (eq tax --name "$dept - cross-list keys (XList)" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-xlist.csv >> $logfile
end

# deptartment codes
set uuid (eq tax --name "$dept - dept codes" | jq -r '.uuid')
if [ $uuid ]
    log "UPDATING TAXONOMY ID $uuid" $logfile
    uptaxo --tid $uuid --pw $pw --un $un \
        --csv $dir/$dept-dept-codes.csv >> $logfile
end
