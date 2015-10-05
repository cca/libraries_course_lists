#!/usr/bin/env fish
# Syllabus Collection is a bit special so gets its own script
# usage:
#   ./syllabus-collection.fish informer.csv

# load log function
source log.fish

set dept SYLLABUS
set dir data
set pw (jq -r '.password' ~/.equellarc)
set un (jq -r '.username' ~/.equellarc)
set filename $argv[1]
set logfile logs/(date "+%Y-%m-%d")-syllabus.txt

# create CSVs for all taxonomies
./get-columns.fish $filename SYLLABUS
# create a couple CSVs not made in any other steps
# XList IDs, deleting the empty row with sed
csvcut -c 7 $filename | tail -n +2 | sort | uniq  | sed -e '/""/d' > $dir/$dept-xlist.csv
and echo "Wrote $dept XList IDs CSV…"
csvcut -c 2 $filename | tail -n +2 | sort | uniq  > $dir/$dept-dept-codes.csv
and echo "Wrote $dept department codes CSV…"
exit
# update all taxonomies
# main course list
set uuid (eq tax --name "$dept - COURSE LIST" | jq -r '.uuid')
# @TODO should a script delete current semester prior?
# place to do it would be in "delete-all-of-a-semester.fish" script
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
